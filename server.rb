#!/usr/bin/env ruby
require "eventmachine"
require "em-http-request"
require "em-websocket"
require "yajl"
require "yaml"
require "net/telnet"
require 'sinatra/base'
require './client.rb'
require 'thin'

CONFIG = YAML.load_file("config.yml")

# ARDUINO = Net::Telnet::new("Host" => "10.55.55.6", "Port" => 80)

def tweet_received(tweet)
  text = tweet[:text]
  user = (! tweet[:user].nil?) ? tweet[:user][:screen_name] : "???"
  @channel.push "#{user}: #{text}" if rand(100) <= 5.0
end

def send_color(rgb)
  # ARDUINO.puts(rgb)
  puts "sending #{rgb}"
end

# Main run loop
EventMachine.run do
  @channel = EM::Channel.new
  @tweet_parser = Yajl::Parser.new(:symbolize_keys => true)
  @tweet_parser.on_parse_complete = method(:tweet_received)

  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen do
      sid = @channel.subscribe { |msg| ws.send msg }
      puts "WebSocket connection open"
      # publish message to the client
      ws.send "Hello Client"
    end
    ws.onmessage do |msg|
      puts "Recieved message: #{msg}"
      ws.send "Pong: #{msg}"
    end
    ws.onclose do
      puts "Connection closed"
    end
  end

  http = EventMachine::HttpRequest.new('https://stream.twitter.com/1/statuses/sample.json').get :head => {'authorization' => [CONFIG["username"], CONFIG["password"]]}
  http.stream do |chunk|
    @tweet_parser << chunk.force_encoding('UTF-8')
  end
  http.errback { puts "oops" }
  http.disconnect { puts "oops, dropped connection?" }

  Client.run!({:port => 3000})
end
