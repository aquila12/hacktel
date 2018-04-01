require_relative 'codes'

module HeaderGenerator
  logotext = 'HACKTEL'
  logocols = [ :red, :yellow, :green, :blue, :magenta, :red, :yellow ]
  LOGO = logotext.chars.zip(logocols).map do |t,c|
    Codes.alphanumeric(c) + t
  end.join

  def self.make_header(pageframe, pence)
    time = Time.now.strftime('%d %b %H:%M')

    layout = [
      LOGO,
      Codes.alphanumeric(:yellow),
      time.ljust(12),
      Codes.alphanumeric(:white),
      pageframe.ljust(7),
      Codes.alphanumeric(:yellow),
      (pence.to_s + "p").rjust(3),
      Codes.move(:return),
      Codes.move(:down)
    ]

    layout.join
  end

  def self.splice_header(header, data)
    firstnl = data.index("\x0a")
    if !firstnl || (firstnl > 39)
      header + data[40..-1]
    else
      header + data[(firstnl+1)..-1]
    end
  end
end
