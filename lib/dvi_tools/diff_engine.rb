# frozen_string_literal: true

module DviTools
  module Diff
  end

  class DiffEngine
    def initialize(file1_path, file2_path, options = {})
      @file1_path = file1_path
      @file2_path = file2_path
      @options = options
    end

    def compare
      data1 = parse_and_analyze(@file1_path)
      data2 = parse_and_analyze(@file2_path)

      result = {}

      unless @options[:content_only] || @options[:fonts_only]
        result[:layout] = DviTools::Diff::Layout.new(data1, data2).compare
      end

      unless @options[:layout_only] || @options[:fonts_only]
        result[:content] = DviTools::Diff::Content.new(data1, data2).compare
      end

      unless @options[:layout_only] || @options[:content_only]
        result[:fonts] = DviTools::Diff::Fonts.new(data1, data2).compare
      end

      result
    end

    private

    def parse_and_analyze(file_path)
      raise FileError, "File not found: #{file_path}" unless File.exist?(file_path)

      begin
        parser = Parser.new(file_path)
        parsed = parser.parse
        analyzer = Analyzer.new(parsed)
      rescue ParseError => e
        raise FileError, "Invalid DVI file: #{e.message}"
      end

      {
        parsed: parsed,
        analyzer: analyzer,
        fonts: analyzer.analyze_fonts,
        layout: analyzer.analyze_layout,
        content: analyzer.analyze_content,
        positions: analyzer.get_character_positions
      }
    end
  end
end

require_relative 'diff/layout'
require_relative 'diff/content'
require_relative 'diff/fonts'
