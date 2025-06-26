# frozen_string_literal: true

module DviTools
  module Diff
    class Layout
      def initialize(data1, data2)
        @data1 = data1
        @data2 = data2
      end

      def compare
        {
          page_count_diff: compare_page_count,
          position_differences: compare_positions,
          dimension_differences: compare_dimensions
        }
      end

      private

      def compare_page_count
        count1 = @data1[:layout][:total_pages]
        count2 = @data2[:layout][:total_pages]

        {
          file1: count1,
          file2: count2,
          difference: count2 - count1,
          changed: count1 != count2
        }
      end

      def compare_positions
        positions1 = @data1[:positions]
        positions2 = @data2[:positions]

        differences = []

        max_length = [positions1.length, positions2.length].max

        (0...max_length).each do |i|
          pos1 = positions1[i]
          pos2 = positions2[i]

          if pos1.nil?
            differences << { type: :added, position: pos2, index: i }
          elsif pos2.nil?
            differences << { type: :removed, position: pos1, index: i }
          elsif pos1[:x] != pos2[:x] || pos1[:y] != pos2[:y] || pos1[:char] != pos2[:char]
            differences << {
              type: :moved,
              from: pos1,
              to: pos2,
              index: i,
              x_diff: pos2[:x] - pos1[:x],
              y_diff: pos2[:y] - pos1[:y]
            }
          end
        end

        {
          total_differences: differences.length,
          differences: differences
        }
      end

      def compare_dimensions
        dims1 = @data1[:layout][:position_ranges]
        dims2 = @data2[:layout][:position_ranges]

        {
          x_range: {
            file1: dims1[:x],
            file2: dims2[:x],
            min_diff: dims2[:x][:min] - dims1[:x][:min],
            max_diff: dims2[:x][:max] - dims1[:x][:max]
          },
          y_range: {
            file1: dims1[:y],
            file2: dims2[:y],
            min_diff: dims2[:y][:min] - dims1[:y][:min],
            max_diff: dims2[:y][:max] - dims1[:y][:max]
          }
        }
      end
    end
  end
end
