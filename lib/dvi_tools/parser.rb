# frozen_string_literal: true

module DviTools
  class Parser
    # DVI opcodes
    SET_CHAR_0 = 0
    SET_CHAR_127 = 127
    SET1 = 128
    SET2 = 129
    SET3 = 130
    SET4 = 131
    SET_RULE = 132
    PUT1 = 133
    PUT2 = 134
    PUT3 = 135
    PUT4 = 136
    PUT_RULE = 137
    NOP = 138
    BOP = 139
    EOP = 140
    PUSH = 141
    POP = 142
    RIGHT1 = 143
    RIGHT2 = 144
    RIGHT3 = 145
    RIGHT4 = 146
    W0 = 147
    W1 = 148
    W2 = 149
    W3 = 150
    W4 = 151
    X0 = 152
    X1 = 153
    X2 = 154
    X3 = 155
    X4 = 156
    DOWN1 = 157
    DOWN2 = 158
    DOWN3 = 159
    DOWN4 = 160
    Y0 = 161
    Y1 = 162
    Y2 = 163
    Y3 = 164
    Y4 = 165
    Z0 = 166
    Z1 = 167
    Z2 = 168
    Z3 = 169
    Z4 = 170
    FNT_NUM_0 = 171
    FNT_NUM_63 = 234
    FNT1 = 235
    FNT2 = 236
    FNT3 = 237
    FNT4 = 238
    XXX1 = 239
    XXX2 = 240
    XXX3 = 241
    XXX4 = 242
    FNT_DEF1 = 243
    FNT_DEF2 = 244
    FNT_DEF3 = 245
    FNT_DEF4 = 246
    PRE = 247
    POST = 248
    POST_POST = 249

    def initialize(file_path)
      @file_path = file_path
      @file = nil
      @position = 0
    end

    def parse
      File.open(@file_path, 'rb') do |file|
        @file = file
        @position = 0
        @file_size = file.size

        {
          preamble: parse_preamble,
          fonts: parse_fonts,
          pages: parse_pages,
          postamble: parse_postamble
        }
      end
    rescue StandardError => e
      raise ParseError, "Failed to parse DVI file: #{e.message}"
    end

    private

    def parse_preamble
      opcode = read_byte
      raise ParseError, "Invalid DVI file: expected PRE (#{PRE}), got #{opcode}" unless opcode == PRE

      {
        format: read_byte,
        numerator: read_uint32,
        denominator: read_uint32,
        magnification: read_uint32,
        comment: read_string(read_byte)
      }
    end

    def parse_fonts
      fonts = {}
      # フォント定義はページ中またはポストアンブルで処理される
      # 基本実装では空のハッシュを返す
      fonts
    end

    def parse_pages
      pages = []

      while @position < @file_size
        opcode = peek_byte
        break if opcode == POST

        if opcode == BOP
          pages << parse_page
        else
          # スキップまたはエラーハンドリング
          read_byte
        end
      end

      pages
    end

    def parse_page
      opcode = read_byte
      raise ParseError, "Expected BOP, got #{opcode}" unless opcode == BOP

      page = {
        counters: Array.new(10) { read_int32 },
        previous_page: read_int32,
        commands: []
      }

      loop do
        break if @position >= @file_size
        
        cmd_opcode = read_byte
        break if cmd_opcode == EOP

        command = parse_command(cmd_opcode)
        page[:commands] << command if command
      end

      page
    end

    def parse_command(opcode)
      case opcode
      when SET_CHAR_0..SET_CHAR_127
        { type: :set_char, char: opcode }
      when SET1
        { type: :set_char, char: read_byte }
      when SET2
        { type: :set_char, char: read_uint16 }
      when SET3
        { type: :set_char, char: read_uint24 }
      when SET4
        { type: :set_char, char: read_uint32 }
      when SET_RULE
        { type: :set_rule, height: read_int32, width: read_int32 }
      when PUT1
        { type: :put_char, char: read_byte }
      when PUT2
        { type: :put_char, char: read_uint16 }
      when PUT3
        { type: :put_char, char: read_uint24 }
      when PUT4
        { type: :put_char, char: read_uint32 }
      when PUT_RULE
        { type: :put_rule, height: read_int32, width: read_int32 }
      when RIGHT1
        { type: :right, distance: read_int8 }
      when RIGHT2
        { type: :right, distance: read_int16 }
      when RIGHT3
        { type: :right, distance: read_int24 }
      when RIGHT4
        { type: :right, distance: read_int32 }
      when DOWN1
        { type: :down, distance: read_int8 }
      when DOWN2
        { type: :down, distance: read_int16 }
      when DOWN3
        { type: :down, distance: read_int24 }
      when DOWN4
        { type: :down, distance: read_int32 }
      when W0
        { type: :w0 }
      when W1
        { type: :w, distance: read_int8 }
      when W2
        { type: :w, distance: read_int16 }
      when W3
        { type: :w, distance: read_int24 }
      when W4
        { type: :w, distance: read_int32 }
      when X0
        { type: :x0 }
      when X1
        { type: :x, distance: read_int8 }
      when X2
        { type: :x, distance: read_int16 }
      when X3
        { type: :x, distance: read_int24 }
      when X4
        { type: :x, distance: read_int32 }
      when Y0
        { type: :y0 }
      when Y1
        { type: :y, distance: read_int8 }
      when Y2
        { type: :y, distance: read_int16 }
      when Y3
        { type: :y, distance: read_int24 }
      when Y4
        { type: :y, distance: read_int32 }
      when Z0
        { type: :z0 }
      when Z1
        { type: :z, distance: read_int8 }
      when Z2
        { type: :z, distance: read_int16 }
      when Z3
        { type: :z, distance: read_int24 }
      when Z4
        { type: :z, distance: read_int32 }
      when FNT_NUM_0..FNT_NUM_63
        { type: :fnt, font_num: opcode - FNT_NUM_0 }
      when FNT1
        { type: :fnt, font_num: read_byte }
      when FNT2
        { type: :fnt, font_num: read_uint16 }
      when FNT3
        { type: :fnt, font_num: read_uint24 }
      when FNT4
        { type: :fnt, font_num: read_uint32 }
      when XXX1
        { type: :special, data: read_string(read_byte) }
      when XXX2
        { type: :special, data: read_string(read_uint16) }
      when XXX3
        { type: :special, data: read_string(read_uint24) }
      when XXX4
        { type: :special, data: read_string(read_uint32) }
      when FNT_DEF1
        parse_font_definition(read_byte)
      when FNT_DEF2
        parse_font_definition(read_uint16)
      when FNT_DEF3
        parse_font_definition(read_uint24)
      when FNT_DEF4
        parse_font_definition(read_uint32)
      when PUSH
        { type: :push }
      when POP
        { type: :pop }
      when NOP
        { type: :nop }
      else
        { type: :unknown, opcode: opcode }
      end
    end

    def parse_postamble
      # POST コマンドを探す
      while @position < @file_size && peek_byte != POST
        read_byte
      end

      return {} if @position >= @file_size

      opcode = read_byte
      raise ParseError, "Expected POST, got #{opcode}" unless opcode == POST

      # POSTアンブルの読み取り（ファイル終端に達した場合は部分的に返す）
      postamble = {}
      
      begin
        postamble[:last_page_pointer] = read_uint32
        postamble[:numerator] = read_uint32
        postamble[:denominator] = read_uint32
        postamble[:magnification] = read_uint32
        postamble[:max_height] = read_uint32
        postamble[:max_width] = read_uint32
        postamble[:max_stack_depth] = read_uint16
        postamble[:total_pages] = read_uint16
      rescue ParseError
        # ファイル終端に達した場合、利用可能な部分だけを返す
      end
      
      postamble
    end

    def parse_font_definition(font_num)
      checksum = read_uint32
      scale_factor = read_uint32
      design_size = read_uint32
      area_name_length = read_byte
      font_name_length = read_byte
      
      area_name = read_string(area_name_length)
      font_name = read_string(font_name_length)
      
      {
        type: :fnt_def,
        font_num: font_num,
        checksum: checksum,
        scale_factor: scale_factor,
        design_size: design_size,
        area_name: area_name,
        font_name: font_name
      }
    end

    # バイト読み取りヘルパーメソッド
    def read_byte
      byte = @file.read(1)
      if byte.nil?
        raise ParseError, "Unexpected end of file at position #{@position} (file size: #{@file_size})"
      end

      @position += 1
      byte.unpack1('C')
    end

    def peek_byte
      pos = @file.pos
      byte = @file.read(1)
      @file.seek(pos)
      byte&.unpack1('C') || 0
    end

    def read_int8
      byte = read_byte
      byte > 127 ? byte - 256 : byte
    end

    def read_uint16
      bytes = @file.read(2)
      raise ParseError, 'Unexpected end of file' if bytes.nil? || bytes.size < 2

      @position += 2
      bytes.unpack1('n')
    end

    def read_int16
      value = read_uint16
      value > 32_767 ? value - 65_536 : value
    end

    def read_uint24
      bytes = @file.read(3)
      raise ParseError, 'Unexpected end of file' if bytes.nil? || bytes.size < 3

      @position += 3
      (bytes.unpack1('C') << 16) | bytes[1..2].unpack1('n')
    end

    def read_int24
      value = read_uint24
      value > 8_388_607 ? value - 16_777_216 : value
    end

    def read_uint32
      bytes = @file.read(4)
      raise ParseError, 'Unexpected end of file' if bytes.nil? || bytes.size < 4

      @position += 4
      bytes.unpack1('N')
    end

    def read_int32
      value = read_uint32
      value > 2_147_483_647 ? value - 4_294_967_296 : value
    end

    def read_string(length)
      return '' if length.zero?

      bytes = @file.read(length)
      raise ParseError, 'Unexpected end of file' if bytes.nil? || bytes.size < length

      @position += length
      bytes.force_encoding('ASCII-8BIT')
    end
  end
end
