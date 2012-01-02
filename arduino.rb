class Arduino
  attr_accessor :color

  def initialize(host, port)
    @connection = Net::Telnet::new("Host" => host, "Port" => port)
  rescue Errno::EPIPE
    puts "Connection to Arduino broken."
    @connection = MockConnection.new
  end

  def send_color
    @connection.puts color
  end

  def color=(color)
    @color = color
  end

  def color
    @color || psuedo_random_rgb
  end

  private

  def random_rgb
    sprintf("#%02x%02x%02x", rand(255), rand(255), rand(255))
  end

  def psuedo_random_rgb
    ["#0000FF",
     "#FF0000",
     "#00FF00",
     "#FFFF00",
     "#FF00FF",
     "#00FFFF",
     "#FFFFFF"
    ][rand(7)]
  end
end

class MockConnection
  def puts(string)
    # Do nothing!
  end
end
