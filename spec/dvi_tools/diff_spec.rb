# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DviTools::DiffEngine do
  let(:file1_path) { 'spec/fixtures/file1.dvi' }
  let(:file2_path) { 'spec/fixtures/file2.dvi' }

  before do
    FileUtils.mkdir_p('spec/fixtures')
  end

  after do
    FileUtils.rm_rf('spec/fixtures')
  end

  describe '#initialize' do
    it 'creates a diff engine instance with file paths and options' do
      diff_engine = described_class.new(file1_path, file2_path, detailed: true)
      expect(diff_engine).to be_a(described_class)
    end
  end

  describe '#compare' do
    context 'with non-existent files' do
      it 'raises FileError for missing first file' do
        diff_engine = described_class.new('/non/existent1.dvi', file2_path)
        expect { diff_engine.compare }.to raise_error(DviTools::FileError, /File not found/)
      end

      it 'raises FileError for missing second file' do
        File.write(file1_path, 'dummy')
        diff_engine = described_class.new(file1_path, '/non/existent2.dvi')
        expect { diff_engine.compare }.to raise_error(DviTools::FileError)
      end
    end

    context 'with option filters' do
      let(:diff_engine) { described_class.new(file1_path, file2_path) }

      before do
        # Create minimal DVI-like files for testing
        File.write(file1_path, 'dummy1')
        File.write(file2_path, 'dummy2')

        # Mock the parse_and_analyze method to avoid actual parsing
        mock_analyzer = double('Analyzer')
        allow(mock_analyzer).to receive(:extract_text).and_return([])

        allow(diff_engine).to receive(:parse_and_analyze).and_return({
                                                                       parsed: {},
                                                                       analyzer: mock_analyzer,
                                                                       fonts: {},
                                                                       layout: { total_pages: 1 },
                                                                       content: { total_characters: 5,
                                                                                  special_commands: [], rules: [] },
                                                                       positions: []
                                                                     })
      end

      it 'compares layout when not filtered out' do
        allow(DviTools::Diff::Layout).to receive(:new).and_return(
          double('LayoutDiff', compare: { layout: 'diff' })
        )

        result = diff_engine.compare
        expect(result).to have_key(:layout)
      end

      it 'skips layout when layout_only is false and others are true' do
        diff_with_options = described_class.new(file1_path, file2_path, content_only: true)
        mock_analyzer = double('Analyzer')
        allow(mock_analyzer).to receive(:extract_text).and_return([])

        allow(diff_with_options).to receive(:parse_and_analyze).and_return({
                                                                             parsed: {},
                                                                             analyzer: mock_analyzer,
                                                                             fonts: {},
                                                                             layout: { total_pages: 1 },
                                                                             content: { total_characters: 5,
                                                                                        special_commands: [], rules: [] },
                                                                             positions: []
                                                                           })

        allow(DviTools::Diff::Content).to receive(:new).and_return(
          double('ContentDiff', compare: { content: 'diff' })
        )

        result = diff_with_options.compare
        expect(result).to have_key(:content)
        expect(result).not_to have_key(:layout)
        expect(result).not_to have_key(:fonts)
      end
    end
  end
end
