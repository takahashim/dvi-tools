# frozen_string_literal: true

module DviTools
  class Reporter
    def initialize(diff_result, options = {})
      @diff_result = diff_result
      @options = options
    end

    def generate_report
      report = []

      report << 'DVI Files Comparison Report'
      report << ('=' * 40)
      report << ''

      if @diff_result[:layout]
        report << format_layout_report(@diff_result[:layout])
        report << ''
      end

      if @diff_result[:content]
        report << format_content_report(@diff_result[:content])
        report << ''
      end

      if @diff_result[:fonts]
        report << format_fonts_report(@diff_result[:fonts])
        report << ''
      end

      report << generate_summary

      report.join("\n")
    end

    def generate_summary
      summary = ['Summary:', '-' * 20]

      total_differences = 0

      if @diff_result[:layout]
        layout_diffs = @diff_result[:layout][:position_differences][:total_differences]
        total_differences += layout_diffs
        summary << "Layout differences: #{layout_diffs}"
      end

      if @diff_result[:content]
        content_diffs = @diff_result[:content][:character_count_diff][:difference].abs
        total_differences += content_diffs
        summary << "Content differences: #{content_diffs}"
      end

      if @diff_result[:fonts]
        font_changes = @diff_result[:fonts][:added_fonts].length +
                       @diff_result[:fonts][:removed_fonts].length +
                       @diff_result[:fonts][:changed_usage].length
        total_differences += font_changes
        summary << "Font differences: #{font_changes}"
      end

      summary << ''
      summary << "Total differences detected: #{total_differences}"
      summary << (total_differences.zero? ? 'Files are identical.' : 'Files have differences.')

      summary.join("\n")
    end

    private

    def format_layout_report(layout_diff)
      report = ['Layout Comparison:', '-' * 20]

      # ページ数の比較
      page_diff = layout_diff[:page_count_diff]
      if page_diff[:changed]
        sign = page_diff[:difference] >= 0 ? '+' : ''
        report << "Page count changed: #{page_diff[:file1]} → #{page_diff[:file2]} (#{sign}#{page_diff[:difference]})"
      else
        report << "Page count: #{page_diff[:file1]} (unchanged)"
      end

      # 位置の違い
      pos_diff = layout_diff[:position_differences]
      if pos_diff[:total_differences].positive?
        report << "Position differences: #{pos_diff[:total_differences]}"

        if @options[:detailed]
          pos_diff[:differences].each do |diff|
            case diff[:type]
            when :added
              report << "  + Added at index #{diff[:index]}: char #{diff[:position][:char]} at (#{diff[:position][:x]}, #{diff[:position][:y]})"
            when :removed
              report << "  - Removed at index #{diff[:index]}: char #{diff[:position][:char]} at (#{diff[:position][:x]}, #{diff[:position][:y]})"
            when :moved
              report << "  ~ Moved at index #{diff[:index]}: (#{diff[:from][:x]}, #{diff[:from][:y]}) → (#{diff[:to][:x]}, #{diff[:to][:y]})"
            end
          end
        end
      else
        report << 'Position differences: 0'
      end

      # 寸法の違い
      dim_diff = layout_diff[:dimension_differences]
      x_changed = dim_diff[:x_range][:min_diff] != 0 || dim_diff[:x_range][:max_diff] != 0
      y_changed = dim_diff[:y_range][:min_diff] != 0 || dim_diff[:y_range][:max_diff] != 0

      if x_changed || y_changed
        report << 'Dimension changes detected:'
        if x_changed
          report << "  X range: #{dim_diff[:x_range][:file1][:min]}..#{dim_diff[:x_range][:file1][:max]} → #{dim_diff[:x_range][:file2][:min]}..#{dim_diff[:x_range][:file2][:max]}"
        end
        if y_changed
          report << "  Y range: #{dim_diff[:y_range][:file1][:min]}..#{dim_diff[:y_range][:file1][:max]} → #{dim_diff[:y_range][:file2][:min]}..#{dim_diff[:y_range][:file2][:max]}"
        end
      else
        report << 'Dimensions: unchanged'
      end

      report.join("\n")
    end

    def format_content_report(content_diff)
      report = ['Content Comparison:', '-' * 20]

      # 文字数の比較
      char_diff = content_diff[:character_count_diff]
      if char_diff[:changed]
        sign = char_diff[:difference] >= 0 ? '+' : ''
        report << "Character count changed: #{char_diff[:file1]} → #{char_diff[:file2]} (#{sign}#{char_diff[:difference]})"
      else
        report << "Character count: #{char_diff[:file1]} (unchanged)"
      end

      # 特殊コマンドの比較
      special_diff = content_diff[:special_commands_diff]
      if special_diff[:changed]
        report << "Special commands changed: #{special_diff[:file1_count]} → #{special_diff[:file2_count]}"
        if @options[:detailed]
          special_diff[:added].each { |cmd| report << "  + Added: #{cmd}" }
          special_diff[:removed].each { |cmd| report << "  - Removed: #{cmd}" }
        end
      else
        report << "Special commands: #{special_diff[:file1_count]} (unchanged)"
      end

      # ルールの比較
      rules_diff = content_diff[:rules_diff]
      if rules_diff[:changed]
        report << "Rules changed: #{rules_diff[:file1_count]} → #{rules_diff[:file2_count]}"
        if @options[:detailed]
          rules_diff[:added].each { |rule| report << "  + Added rule: #{rule}" }
          rules_diff[:removed].each { |rule| report << "  - Removed rule: #{rule}" }
        end
      else
        report << "Rules: #{rules_diff[:file1_count]} (unchanged)"
      end

      # テキストの違い
      text_diff = content_diff[:text_differences]
      if text_diff[:pages_with_differences].positive?
        report << "Pages with text differences: #{text_diff[:pages_with_differences]}"
        if @options[:detailed]
          text_diff[:differences].each do |page_diff|
            report << "  Page #{page_diff[:page] + 1}: #{page_diff[:file1_chars]} → #{page_diff[:file2_chars]} characters"
            if page_diff[:text1] != page_diff[:text2]
              report << "    Old text: #{page_diff[:text1][0..100]}#{page_diff[:text1].length > 100 ? '...' : ''}"
              report << "    New text: #{page_diff[:text2][0..100]}#{page_diff[:text2].length > 100 ? '...' : ''}"
            end
          end
        end
      else
        report << 'Text content: identical'
      end

      report.join("\n")
    end

    def format_fonts_report(fonts_diff)
      report = ['Font Comparison:', '-' * 20]

      usage_diff = fonts_diff[:font_usage_diff]
      if usage_diff[:different]
        report << "Font usage changed: #{usage_diff[:file1_font_count]} → #{usage_diff[:file2_font_count]} fonts"
        report << "Common fonts: #{usage_diff[:common_fonts]}"
      else
        report << "Font usage: #{usage_diff[:file1_font_count]} fonts (unchanged)"
      end

      # 追加されたフォント
      unless fonts_diff[:added_fonts].empty?
        report << 'Added fonts:'
        fonts_diff[:added_fonts].each do |font|
          if @options[:detailed] && font[:pages]
            report << "  + Font #{font[:font_num]}: used #{font[:usage_count]} times on pages #{font[:pages].join(', ')}"
          else
            report << "  + Font #{font[:font_num]}: used #{font[:usage_count]} times"
          end
        end
      end

      # 削除されたフォント
      unless fonts_diff[:removed_fonts].empty?
        report << 'Removed fonts:'
        fonts_diff[:removed_fonts].each do |font|
          if @options[:detailed] && font[:pages]
            report << "  - Font #{font[:font_num]}: was used #{font[:usage_count]} times on pages #{font[:pages].join(', ')}"
          else
            report << "  - Font #{font[:font_num]}: was used #{font[:usage_count]} times"
          end
        end
      end

      # 使用量が変わったフォント
      unless fonts_diff[:changed_usage].empty?
        report << 'Changed font usage:'
        fonts_diff[:changed_usage].each do |font|
          sign = font[:usage_diff] >= 0 ? '+' : ''
          report << "  ~ Font #{font[:font_num]}: #{font[:file1_usage]} → #{font[:file2_usage]} (#{sign}#{font[:usage_diff]})"
        end
      end

      report.join("\n")
    end
  end
end
