# frozen_string_literal: true

module DviTools
  module Diff
    class Fonts
      def initialize(data1, data2)
        @data1 = data1
        @data2 = data2
      end

      def compare
        fonts1 = @data1[:fonts]
        fonts2 = @data2[:fonts]

        {
          font_usage_diff: compare_font_usage(fonts1, fonts2),
          added_fonts: find_added_fonts(fonts1, fonts2),
          removed_fonts: find_removed_fonts(fonts1, fonts2),
          changed_usage: find_changed_usage(fonts1, fonts2)
        }
      end

      private

      def compare_font_usage(fonts1, fonts2)
        {
          file1_font_count: fonts1.keys.length,
          file2_font_count: fonts2.keys.length,
          common_fonts: (fonts1.keys & fonts2.keys).length,
          different: fonts1.keys.sort != fonts2.keys.sort
        }
      end

      def find_added_fonts(fonts1, fonts2)
        (fonts2.keys - fonts1.keys).map do |font_num|
          {
            font_num: font_num,
            usage_count: fonts2[font_num][:usage_count],
            pages: fonts2[font_num][:pages]
          }
        end
      end

      def find_removed_fonts(fonts1, fonts2)
        (fonts1.keys - fonts2.keys).map do |font_num|
          {
            font_num: font_num,
            usage_count: fonts1[font_num][:usage_count],
            pages: fonts1[font_num][:pages]
          }
        end
      end

      def find_changed_usage(fonts1, fonts2)
        common_fonts = fonts1.keys & fonts2.keys

        common_fonts.filter_map do |font_num|
          usage1 = fonts1[font_num][:usage_count]
          usage2 = fonts2[font_num][:usage_count]

          next unless usage1 != usage2

          {
            font_num: font_num,
            file1_usage: usage1,
            file2_usage: usage2,
            usage_diff: usage2 - usage1
          }
        end
      end
    end
  end
end
