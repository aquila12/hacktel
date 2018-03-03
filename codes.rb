module Codes
  NUL="\x00"
  ENO="\x05"
  ESC="\x1b"
  CS="\x0c"

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

  Conceal = ESC + 'X'
  BlackBackground = ESC + '\\'
  NewBackground = ESC + ']'

  def self.cursor(flag)
    on_off( "\x11", "\x14" )
  end

  def self.double_height(flag)
    ESC + on_off('M','L')
  end

  def self.flash(flag)
    ESC + on_off('H','I')
  end

  def self.hold_mosaics(flag)
    ESC + on_off('^','_')
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
    ESC + colour_select_char( colour, '@ABCDEFG' )
  end

  def self.mosaic(colour)
    ESC + colour_select_char( colour, 'PQRSTUVW' )
  end
end
