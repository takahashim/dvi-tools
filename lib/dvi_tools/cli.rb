# frozen_string_literal: true

require 'thor'

module DviTools
  class CLI < Thor
    desc 'parse FILE', 'Parse and analyze a DVI file'
    option :format, type: :string, default: 'summary', desc: 'Output format (summary, detailed, json)'
    def parse(file_path)
      check_file_exists(file_path)

      parser = Parser.new(file_path)
      parsed_data = parser.parse
      analyzer = Analyzer.new(parsed_data)

      case options[:format]
      when 'json'
        require 'json'
        puts JSON.pretty_generate({
                                    preamble: parsed_data[:preamble],
                                    fonts: analyzer.analyze_fonts,
                                    layout: analyzer.analyze_layout,
                                    content: analyzer.analyze_content
                                  })
      when 'detailed'
        print_detailed_analysis(parsed_data, analyzer)
      else
        print_summary_analysis(parsed_data, analyzer)
      end
    rescue Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'diff FILE1 FILE2', 'Compare two DVI files'
    option :detailed, type: :boolean, desc: 'Generate detailed report'
    option :layout_only, type: :boolean, desc: 'Compare layout only'
    option :content_only, type: :boolean, desc: 'Compare content only'
    option :fonts_only, type: :boolean, desc: 'Compare fonts only'
    option :ignore_timestamps, type: :boolean, desc: 'Ignore timestamp differences'
    def diff(file1_path, file2_path)
      check_file_exists(file1_path)
      check_file_exists(file2_path)

      diff_engine = DiffEngine.new(file1_path, file2_path, options)
      result = diff_engine.compare

      reporter = Reporter.new(result, options)
      puts reporter.generate_report
    rescue Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'analyze ASPECT FILE', 'Analyze specific aspect of DVI file'
    def analyze(aspect, file_path)
      check_file_exists(file_path)

      parser = Parser.new(file_path)
      parsed_data = parser.parse
      analyzer = Analyzer.new(parsed_data)

      case aspect.downcase
      when 'fonts'
        puts format_fonts_analysis(analyzer.analyze_fonts)
      when 'layout'
        puts format_layout_analysis(analyzer.analyze_layout)
      when 'content'
        puts format_content_analysis(analyzer.analyze_content)
      when 'text'
        puts format_text_analysis(analyzer.extract_text)
      when 'positions'
        puts format_positions_analysis(analyzer.get_character_positions)
      else
        puts "Unknown aspect: #{aspect}"
        puts 'Available aspects: fonts, layout, content, text, positions'
        exit 1
      end
    rescue Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'version', 'Show version information'
    def version
      puts "dvi-tools version #{VERSION}"
    end

    private

    def check_file_exists(file_path)
      return if File.exist?(file_path)

      puts "Error: File not found: #{file_path}"
      exit 1
    end

    def print_summary_analysis(parsed_data, analyzer)
      puts 'DVI File Analysis Summary'
      puts '=' * 30
      puts

      # プリアンブル情報
      preamble = parsed_data[:preamble]
      puts "Format version: #{preamble[:format]}"
      puts "Magnification: #{preamble[:magnification]}"
      puts "Comment: #{preamble[:comment]}" unless preamble[:comment].empty?
      puts

      # 基本統計
      layout = analyzer.analyze_layout
      content = analyzer.analyze_content
      fonts = analyzer.analyze_fonts

      puts "Pages: #{layout[:total_pages]}"
      puts "Total characters: #{content[:total_characters]}"
      puts "Fonts used: #{fonts.keys.length}"
      puts "Special commands: #{content[:special_commands].length}"
      puts "Rules: #{content[:rules].length}"
    end

    def print_detailed_analysis(parsed_data, analyzer)
      print_summary_analysis(parsed_data, analyzer)
      puts
      puts 'Detailed Analysis'
      puts '-' * 20
      puts

      puts format_fonts_analysis(analyzer.analyze_fonts)
      puts
      puts format_layout_analysis(analyzer.analyze_layout)
      puts
      puts format_content_analysis(analyzer.analyze_content)
    end

    def format_fonts_analysis(fonts)
      return 'No fonts used' if fonts.empty?

      result = ['Font Usage:']
      fonts.each do |font_num, info|
        result << "  Font #{font_num}: #{info[:usage_count]} times on pages #{info[:pages].join(', ')}"
      end
      result.join("\n")
    end

    def format_layout_analysis(layout)
      result = ['Layout Information:']
      result << "  Total pages: #{layout[:total_pages]}"
      result << "  X range: #{layout[:position_ranges][:x][:min]} to #{layout[:position_ranges][:x][:max]}"
      result << "  Y range: #{layout[:position_ranges][:y][:min]} to #{layout[:position_ranges][:y][:max]}"

      if layout[:page_dimensions].any?
        result << '  Page details:'
        layout[:page_dimensions].each_with_index do |page, index|
          result << "    Page #{index + 1}: #{page[:character_count]} chars, #{page[:commands_count]} commands"
        end
      end

      result.join("\n")
    end

    def format_content_analysis(content)
      result = ['Content Information:']
      result << "  Total characters: #{content[:total_characters]}"
      result << "  Special commands: #{content[:special_commands].length}"
      result << "  Rules: #{content[:rules].length}"

      unless content[:special_commands].empty?
        result << '  Special command examples:'
        content[:special_commands].first(3).each do |cmd|
          result << "    #{cmd.inspect}"
        end
      end

      result.join("\n")
    end

    def format_text_analysis(text_by_page)
      result = ['Text Content:']

      text_by_page.each_with_index do |page, index|
        chars = page.map { |item| item[:char] }.join
        result << "  Page #{index + 1}: #{chars.length} characters"
        result << "    Preview: #{chars[0..50].inspect}..." if chars.length > 50
        result << "    Content: #{chars.inspect}" if chars.length <= 50
      end

      result.join("\n")
    end

    def format_positions_analysis(positions)
      result = ['Character Positions:']
      result << "  Total positioned characters: #{positions.length}"

      if positions.any?
        result << '  Position examples:'
        positions.first(5).each do |pos|
          char_display = begin
            pos[:char].chr(Encoding::ASCII_8BIT)
          rescue StandardError
            "\\#{pos[:char]}"
          end
          result << "    '#{char_display}' at (#{pos[:x]}, #{pos[:y]}) on page #{pos[:page]}"
        end
      end

      result.join("\n")
    end
  end
end
