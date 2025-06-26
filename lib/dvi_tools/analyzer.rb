# frozen_string_literal: true

module DviTools
  class Analyzer
    def initialize(parsed_data)
      @data = parsed_data
    end

    def analyze_fonts
      fonts = {}

      @data[:pages].each do |page|
        page[:commands].each do |command|
          next unless command[:type] == :fnt

          font_num = command[:font_num]
          fonts[font_num] ||= { usage_count: 0, pages: [] }
          fonts[font_num][:usage_count] += 1
          fonts[font_num][:pages] << page[:counters][0] unless fonts[font_num][:pages].include?(page[:counters][0])
        end
      end

      fonts
    end

    def analyze_layout
      layout = {
        total_pages: @data[:pages].size,
        page_dimensions: [],
        position_ranges: { x: { min: 0, max: 0 }, y: { min: 0, max: 0 } }
      }

      @data[:pages].each_with_index do |page, _index|
        page_layout = analyze_page_layout(page)
        layout[:page_dimensions] << page_layout

        # 全体の位置範囲を更新
        merge_position_ranges(layout[:position_ranges], page_layout[:position_ranges])
      end

      layout
    end

    def analyze_content
      content = {
        total_characters: 0,
        special_commands: [],
        rules: []
      }

      @data[:pages].each do |page|
        page[:commands].each do |command|
          case command[:type]
          when :set_char, :put_char
            content[:total_characters] += 1
          when :special
            content[:special_commands] << command[:data]
          when :set_rule, :put_rule
            content[:rules] << command
          end
        end
      end

      content
    end

    def extract_text
      text_by_page = []

      @data[:pages].each do |page|
        page_text = []
        current_position = { x: 0, y: 0 }

        page[:commands].each do |command|
          case command[:type]
          when :set_char, :put_char
            char_code = command[:char]
            page_text << {
              char: char_code.chr(Encoding::ASCII_8BIT),
              position: current_position.dup
            }
            current_position[:x] += 1 if command[:type] == :set_char # 概算
          when :right
            current_position[:x] += command[:distance] || 0
          when :down
            current_position[:y] += command[:distance] || 0
          end
        end

        text_by_page << page_text
      end

      text_by_page
    end

    def get_character_positions
      positions = []

      @data[:pages].each_with_index do |page, page_num|
        current_position = { x: 0, y: 0 }
        stack = []

        page[:commands].each do |command|
          case command[:type]
          when :set_char, :put_char
            positions << {
              page: page_num,
              char: command[:char],
              x: current_position[:x],
              y: current_position[:y]
            }
            current_position[:x] += 1 if command[:type] == :set_char # 概算
          when :right
            current_position[:x] += command[:distance] || 0
          when :down
            current_position[:y] += command[:distance] || 0
          when :push
            stack.push(current_position.dup)
          when :pop
            current_position = stack.pop || { x: 0, y: 0 }
          end
        end
      end

      positions
    end

    private

    def analyze_page_layout(page)
      layout = {
        commands_count: page[:commands].size,
        character_count: 0,
        position_ranges: { x: { min: 0, max: 0 }, y: { min: 0, max: 0 } }
      }

      current_position = { x: 0, y: 0 }

      page[:commands].each do |command|
        case command[:type]
        when :set_char, :put_char
          layout[:character_count] += 1
          update_position_ranges(layout[:position_ranges], current_position)
          current_position[:x] += 1 if command[:type] == :set_char # 概算
        when :right
          current_position[:x] += command[:distance] || 0
          update_position_ranges(layout[:position_ranges], current_position)
        when :down
          current_position[:y] += command[:distance] || 0
          update_position_ranges(layout[:position_ranges], current_position)
        end
      end

      layout
    end

    def update_position_ranges(ranges, position)
      pos_x = position.is_a?(Hash) ? position[:x] : position
      pos_y = position.is_a?(Hash) ? position[:y] : 0

      ranges[:x][:min] = [ranges[:x][:min], pos_x].min
      ranges[:x][:max] = [ranges[:x][:max], pos_x].max
      ranges[:y][:min] = [ranges[:y][:min], pos_y].min
      ranges[:y][:max] = [ranges[:y][:max], pos_y].max
    end

    def merge_position_ranges(global_ranges, page_ranges)
      global_ranges[:x][:min] = [global_ranges[:x][:min], page_ranges[:x][:min]].min
      global_ranges[:x][:max] = [global_ranges[:x][:max], page_ranges[:x][:max]].max
      global_ranges[:y][:min] = [global_ranges[:y][:min], page_ranges[:y][:min]].min
      global_ranges[:y][:max] = [global_ranges[:y][:max], page_ranges[:y][:max]].max
    end
  end
end
