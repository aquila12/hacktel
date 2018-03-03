module Codes
  NUL="\x00"
  ENO="\x05"
  ESC="\x1b"
  CS="\x0c"

  def self.escape(char)
    ESC + char
  end

  def self.move(where)
    case where
    when :left, :backward, :back; "\x08"
    when :right, :forward; "\x09"
    when :up; "\x0b"
    when :down; "\x0a"
    when :return; "\x0d"
    when :home; "\x1e"
    else; raise ArgumentError.new "#{where.to_s} is not a valid movement"
    end
  end

  def self.on_off(onstr, offstr)
    case flag
    when :on; onstr
    when :off; offstr
    else; raise ArgumentError.new "#{flag.to_s} is not a valid flag state"
    end
  end

  Conceal = escape 'X'
  BlackBackground = escape "\x5c"
  NewBackground = escape "\x5d"

  def self.cursor(flag)
    on_off( "\x11", "\x14" )
  end

  def self.double_height(flag)
    on_off escape('M'), escape('L')
  end

  def self.flash(flag)
    on_off escape('H'), escape('I')
  end

  def self.hold_mosaics(flag)
    on_off escape('^'), escape('_')
  end

  def self.colour_select_char(colour, characters)
    index = {
      black: 0,
      red: 1,
      green: 2,
      yellow: 3,
      blue: 4,
      magenta: 5,
      cyan: 6,
      white: 7,
    }[colour]

    raise ArgumentError.new "#{colour.to_s} is not a valid colour" unless index
    characters[index]
  end

  def self.alphanumeric(colour)
    escape colour_select_char( colour, '@ABCDEFG' )
  end

  def self.mosaic(colour)
    escape colour_select_char( colour, 'PQRSTUVW' )
  end
end
