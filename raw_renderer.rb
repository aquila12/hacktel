class RawRenderer
  def initialize(opts)
    @control_range        = opts[:control_range]        || ( 0x00..0x1f )
    @insert_line_returns  = opts[:insert_line_returns]  || false
  end

  def render(data)
    if @insert_line_returns
      lines = data.chars.each_slice(40).map { |a| a.join }
    else
      lines = data.split("\x0a")
    end

    lines[0..23].join.bytes.map do |c|
      if @control_range.include? c
        [27, 64 + c]
      else
        c
      end
    end.flatten.pack('c*')
  end
end
