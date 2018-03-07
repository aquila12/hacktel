#!/usr/bin/env ruby
# H A C K T E L server

require 'io/console'

require_relative 'codes'
require_relative 'header_generator'
require_relative 'native_renderer'
require_relative 'raw_renderer'
require_relative 'edit_tf'

PAGEDIR=ARGV.shift
HOME=ARGV.shift || '1'

unless PAGEDIR
  STDERR.puts "No pagedir specified"
  exit 1
end

$renderers = {
  'vdat' => NativeRenderer.new,
  'fram' => RawRenderer.new( 0x00..0x1f ),
  'raw0' => RawRenderer.new( 0x00..0x1f ),
  'raw2' => RawRenderer.new( 0x80..0x9f ),
}

def renderFile(filename)
  $renderers.each do |ext, renderer|
    begin
      data = File.read("#{PAGEDIR}/#{filename}.#{ext}").force_encoding(Encoding::BINARY)

      return renderer.render(data)
    rescue Errno::ENOENT
      next
    end
  end
  return false
end

def clearKeypresses
  begin
    while STDIN.read_nonblock(1); end
  rescue IO::WaitReadable
  end
end

STDOUT.binmode
STDOUT.sync = true

page=HOME
frame='a'
while(true)
  pf = page + frame
  STDERR.puts "Frame: #{pf}"
  # Render bit
  data = renderFile(pf)
  unless data
    if frame == 'a'
      data = renderFile("notfound") unless data
      data = "404: #{msg}" unless data

      msg = "No frame at #{pf}!"
      STDERR.puts msg
    else
      frame='a'
      next
    end
  end

  if data
    hdr = HeaderGenerator.make_header(pf, 0)
    data = HeaderGenerator.splice_header(hdr, data)

    STDERR.puts "Edit: #{EditTF.uri(data)}"
    STDOUT.write Codes::CS + data
  end

  # Input bit
  clearKeypresses
  c = nil
  begin
    c = ( STDIN.tty? ? STDIN.getch : STDIN.getc )
    STDERR.puts "Key: #{c.inspect}"

    case c
    when "\u0003";    exit 0      # CTRL+C: quit
    when '_';         frame.next! # Enter:  next frame in page
    when ('0'..'7')               # Number press - navigate
      page += c
      frame = 'a'
    when '8'                      # 8 - home
      page = HOME
      frame = 'a'
    when '9'
      page = page[0..-2]          # Drop the last character
      page = HOME if page.empty?
      frame = 'a'
    else
      c = nil
    end
  end until c
end
