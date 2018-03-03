class RawRenderer
  def initialize(control_range)
    @control_range = control_range
  end

  def render(data)
    data.split("\x0a")[0..23].join.bytes.map do |c|
      if @control_range.include? c
        [27, 64 + c]
      else
        c
      end
    end.flatten.pack('c*')
  end
end
