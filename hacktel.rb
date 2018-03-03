#!/usr/bin/env ruby
# H A C K T E L server

require_relative 'codes'
require_relative 'header_generator'

PAGEDIR=ARGV.shift
RENDER_ORDER=['vdat','fram']

unless PAGEDIR
  STDERR.puts "No pagedir specified"
  exit 1
end

$renderers = {}

# Raw viewdata format
$renderers['vdat'] = Proc.new { |data| data }

# Raw frame format with extraneous newlines, and possibly extra line at the bottom
$renderers['fram'] = Proc.new do |data|
  data.split("\x0a")[0..23].join.bytes.map do |c|
    (c < 32) ? [27, c + 64] : c
  end.flatten.pack('c*')
end

def renderFile(filename)
  RENDER_ORDER.each do |ext|
    begin
      return $renderers[ext].call(File.read("#{PAGEDIR}/#{filename}.#{ext}").force_encoding(Encoding::BINARY))
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
