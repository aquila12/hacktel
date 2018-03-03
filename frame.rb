require_relative 'codes'

class Frame
  def initialize(cols, lines)
    @lines = lines
    @cols = cols
    clear
  end

  def clear
    @scr = Array.new(@lines){ [' '] * @cols }
    @x = 0
    @y = 0
    @esccode = false
  end

  def handle(stream)
    stream.chars.each do |c|
      if @esccode
        @scr[@y][@x] = [ c.bytes.first - 64 ].pack('c*')
        @x += 1
        @esccode = false
      else
        case c
        when Codes::ESC;  @esccode = true
        when Codes::CS;   clear
        when Codes.move( :left   ) ; @x -= 1
        when Codes.move( :right  ) ; @x += 1
        when Codes.move( :down   ) ; @y += 1
        when Codes.move( :up     ) ; @y -= 1
        when Codes.move( :return ) ; @x = 0
        when Codes.move( :home   ) ; @x = 0; @y = 0
        else
          @scr[@y][@x] = c
          @x += 1
        end
      end

      if @x >= @cols
        @x = 0
        @y += 1
      end
      if @y >= @lines
        @y = 0
      end
    end
  end

  def dump
    @scr.flatten.join
  end
end
