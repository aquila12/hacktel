require_relative 'frame'

module EditTF
  CODE='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'

  def self.uri_data(data)
    f = Frame.new(40, 25)
    f.handle(data)

    raw_data = f.dump.bytes.map{ |b| b.to_s(2).rjust(7,'0')[0..6] }.join

    output = ''
    raw_data.chars.each_slice(6) do |s|
      output += CODE[s.join.ljust(6,'0').to_i(2)]
    end

    output
  end

  def self.uri(data)
    "http://edit.tf/\#0:#{self.uri_data(data)}"
  end
end
