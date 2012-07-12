class Arduino
  def initialize(host, port)
    @connection = Net::Telnet::new("Host" => host, "Port" => port)
  rescue Errno::EPIPE
    mock_connection
  end

  def send_color
    if ! @color.blank? && @color.class.method_defined?(:to_s)
      @connection.puts @color.to_s
    end
  rescue Errno::EPIPE
    mock_connection
  end

  def color=(color)
    @color = color
  end

  private

  def mock_connection
    puts "Connection to Arduino broken."
    @connection = MockConnection.new
  end
end

class MockConnection
  def puts(string)
    # Do nothing!
  end
end
