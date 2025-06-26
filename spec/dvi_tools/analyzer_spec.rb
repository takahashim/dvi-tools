# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DviTools::Analyzer do
  let(:sample_parsed_data) do
    {
      preamble: {
        format: 2,
        numerator: 25_400_000,
        denominator: 473_628_672,
        magnification: 1000,
        comment: 'Test document'
      },
      fonts: {},
      pages: [
        {
          counters: [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          previous_page: -1,
          commands: [
            { type: :set_char, char: 72 },  # 'H'
            { type: :set_char, char: 101 }, # 'e'
            { type: :set_char, char: 108 }, # 'l'
            { type: :set_char, char: 108 }, # 'l'
            { type: :set_char, char: 111 }, # 'o'
            { type: :right, distance: 100 },
            { type: :set_char, char: 87 },  # 'W'
            { type: :set_char, char: 111 }, # 'o'
            { type: :set_char, char: 114 }, # 'r'
            { type: :set_char, char: 108 }, # 'l'
            { type: :set_char, char: 100 }, # 'd'
            { type: :fnt, font_num: 0 },
            { type: :special, data: 'pdf:dest (page1) [@thispage /XYZ @xpos @ypos null]' }
          ]
        }
      ],
      postamble: {}
    }
  end

  let(:analyzer) { described_class.new(sample_parsed_data) }

  describe '#analyze_fonts' do
    it 'returns font usage statistics' do
      result = analyzer.analyze_fonts
      expect(result).to be_a(Hash)
      expect(result[0]).to include(usage_count: 1, pages: [1])
    end

    it 'handles pages without font changes' do
      data_without_fonts = sample_parsed_data.dup
      data_without_fonts[:pages][0][:commands] = [
        { type: :set_char, char: 65 }
      ]
      analyzer = described_class.new(data_without_fonts)

      result = analyzer.analyze_fonts
      expect(result).to be_empty
    end
  end

  describe '#analyze_layout' do
    it 'returns layout analysis' do
      result = analyzer.analyze_layout
      expect(result).to include(
        total_pages: 1,
        page_dimensions: be_an(Array),
        position_ranges: be_a(Hash)
      )
    end

    it 'calculates position ranges correctly' do
      result = analyzer.analyze_layout
      ranges = result[:position_ranges]
      expect(ranges).to have_key(:x)
      expect(ranges).to have_key(:y)
      expect(ranges[:x]).to include(:min, :max)
      expect(ranges[:y]).to include(:min, :max)
    end
  end

  describe '#analyze_content' do
    it 'returns content analysis' do
      result = analyzer.analyze_content
      expect(result).to include(
        total_characters: 10,
        special_commands: ['pdf:dest (page1) [@thispage /XYZ @xpos @ypos null]'],
        rules: []
      )
    end

    it 'counts set_char and put_char commands' do
      result = analyzer.analyze_content
      expect(result[:total_characters]).to eq(10)
    end
  end

  describe '#extract_text' do
    it 'extracts text content by page' do
      result = analyzer.extract_text
      expect(result).to be_an(Array)
      expect(result.size).to eq(1)

      page_text = result[0]
      chars = page_text.map { |item| item[:char] }
      expect(chars.join).to include('Hello', 'World')
    end

    it 'includes position information' do
      result = analyzer.extract_text
      page_text = result[0]

      expect(page_text[0]).to include(char: 'H', position: { x: 0, y: 0 })
    end
  end

  describe '#get_character_positions' do
    it 'returns character positions with coordinates' do
      result = analyzer.get_character_positions
      expect(result).to be_an(Array)
      expect(result.size).to eq(10)

      first_char = result[0]
      expect(first_char).to include(
        page: 0,
        char: 72,
        x: 0,
        y: 0
      )
    end

    it 'handles movement commands correctly' do
      result = analyzer.get_character_positions
      # After 'Hello' and a right movement, 'W' should be at x position > 5
      world_start = result.find { |pos| pos[:char] == 87 } # 'W'
      expect(world_start[:x]).to be > 5
    end
  end
end
