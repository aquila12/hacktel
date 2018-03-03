#!/usr/bin/env ruby
# H A C K T E L server

require_relative 'codes'
require_relative 'header_generator'
require_relative 'native_renderer'
require_relative 'raw_renderer'

PAGEDIR=ARGV.shift
RENDER_ORDER=['vdat','fram']

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

page='1'
frame='a'
while(true)
  pf = page + frame
  STDERR.puts "Frame: #{pf}"
  # Render bit
  data = renderFile(pf)
  unless data
    if frame == 'a'
      data = renderFile("notfound") unless data

      msg = "No frame at #{pf}!"
      STDERR.puts msg
      # TODO: Try the last page
      STDOUT.write Codes::CS + "404: #{msg}"
    else
      frame='a'
      next
    end
  end

  if data
    hdr = HeaderGenerator.make_header(pf, 0)
    data = HeaderGenerator.splice_header(hdr, data)

    STDOUT.write Codes::CS + data
  end

  # Input bit
  clearKeypresses
  c = nil
  begin
    c = STDIN.getc
    STDERR.puts "Key: #{c}"
    case c
    when '_'        # Enter
      frame.next!
    when ('0'..'7') # Number press
      page += c
      frame = 'a'
    when '8'
      page = '1'
      frame = 'a'
    when '9'
      page = page[0..-2]
      page = "1" if page.empty?
      frame = 'a'
    else
      c = nil
    end
  end until c
end
