# frozen_string_literal: true

module DviTools
  module Diff
    class Content
      def initialize(data1, data2)
        @data1 = data1
        @data2 = data2
      end

      def compare
        {
          character_count_diff: compare_character_count,
          special_commands_diff: compare_special_commands,
          rules_diff: compare_rules,
          text_differences: compare_text_content
        }
      end

      private

      def compare_character_count
        count1 = @data1[:content][:total_characters]
        count2 = @data2[:content][:total_characters]

        {
          file1: count1,
          file2: count2,
          difference: count2 - count1,
          changed: count1 != count2
        }
      end

      def compare_special_commands
        specials1 = @data1[:content][:special_commands] || []
        specials2 = @data2[:content][:special_commands] || []

        {
          file1_count: specials1.length,
          file2_count: specials2.length,
          added: specials2 - specials1,
          removed: specials1 - specials2,
          changed: specials1 != specials2
        }
      end

      def compare_rules
        rules1 = @data1[:content][:rules] || []
        rules2 = @data2[:content][:rules] || []

        {
          file1_count: rules1.length,
          file2_count: rules2.length,
          added: rules2 - rules1,
          removed: rules1 - rules2,
          changed: rules1 != rules2
        }
      end

      def compare_text_content
        text1 = @data1[:analyzer].extract_text
        text2 = @data2[:analyzer].extract_text

        differences = []

        max_pages = [text1.length, text2.length].max

        (0...max_pages).each do |page_num|
          page1 = text1[page_num] || []
          page2 = text2[page_num] || []

          page_diff = compare_page_text(page1, page2, page_num)
          differences << page_diff if page_diff[:changed]
        end

        {
          pages_with_differences: differences.length,
          differences: differences
        }
      end

      def compare_page_text(page1, page2, page_num)
        chars1 = page1.map { |item| item[:char] }
        chars2 = page2.map { |item| item[:char] }

        {
          page: page_num,
          file1_chars: chars1.length,
          file2_chars: chars2.length,
          text1: chars1.join,
          text2: chars2.join,
          changed: chars1 != chars2
        }
      end
    end
  end
end
