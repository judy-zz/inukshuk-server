#!/usr/bin/env ruby
require "eventmachine"
require "em-http-request"
require "yajl"
require "yaml"
require "net/telnet"

CONFIG = YAML.load_file("config.yml")

ARDUINO = @Net::Telnet::new("Host" => "10.55.55.6", "Port" => 80)

def tweet_received(tweet)
  text = tweet[:text]
  user = (! tweet[:user].nil?) ? tweet[:user][:screen_name] : "???"
  puts "#{user}: #{text}"
  
end

def send_color(rgb)
  ARDUINO.puts(rgb)
end

# Main run loop
EventMachine.run do
  @parser = Yajl::Parser.new(:symbolize_keys => true)
  @parser.on_parse_complete = method(:tweet_received)
  http = EventMachine::HttpRequest.new('https://stream.twitter.com/1/statuses/sample.json').get :head => {'authorization' => [CONFIG["username"], CONFIG["password"]]}
  

  http.stream do |chunk|
    @parser << chunk
  end

  http.errback { puts "oops" }
  http.disconnect { puts "oops, dropped connection?" }
end