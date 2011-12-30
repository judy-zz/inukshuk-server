#!/usr/bin/env ruby
require "eventmachine"
require "em-http-request"
require "em-websocket"
require "yajl"
require "yaml"
require 'sinatra/base'
require 'haml'
require 'thin'
require 'json'
require 'net/telnet'
require "active_support/core_ext"
require 'profanity_filter'

require './client.rb'

$CONFIG = YAML.load_file("config.yml")
TIME_BETWEEN_CHANGING_TWEETS = 5
TIME_BETWEEN_CHANGING_COLORS = 0.01

def tweet_received(tweet)
  if tweet[:text] && rand(100) <= 2.0
    text = ProfanityFilter::Base.clean(tweet[:text], 'hollow')
    user = (! tweet[:user].nil?) ? tweet[:user][:screen_name] : "???"
    color = Arduino.random_rgb
    @tweet_queue.push(:message => {:user => user, :text => text, :color => color}.to_json, :color => color)
  end
end


class Arduino
  @color = "#111111"
  @connection = Net::Telnet::new("Host" => $CONFIG["arduino"]["host"], "Port" => $CONFIG["arduino"]["port"])

  class << self
    attr_accessor :color
    attr_reader :connection

    def send_color
      puts "sending #{color}"
      Arduino.connection.puts Arduino.color
    end

    def random_rgb
      # sprintf("#%02x%02x%02x", rand(255), rand(255), rand(255))
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
end


# Main run loop
EventMachine.run do
  @tweet_queue = EM::Queue.new
  @color_queue = EM::Queue.new
  @tweet_parser = Yajl::Parser.new(:symbolize_keys => true)
  @tweet_parser.on_parse_complete = method(:tweet_received)

  EventMachine::PeriodicTimer.new(TIME_BETWEEN_CHANGING_COLORS) do
    Arduino.send_color
  end

  EventMachine::WebSocket.start(:host => "localhost", :port => 8080) do |ws|
    ws.onopen do
      puts "WebSocket connection open"
    end
    EventMachine::PeriodicTimer.new(TIME_BETWEEN_CHANGING_TWEETS) do
      @tweet_queue.pop do |msg|
        ws.send msg[:message].force_encoding('UTF-8')
        Arduino.color = msg[:color]
      end
    end
    ws.onmessage do |msg|
      puts "Received message: #{msg}"
    end
    ws.onclose do
      puts "Connection closed"
    end
  end

  http = EventMachine::HttpRequest.new('https://stream.twitter.com/1/statuses/sample.json').get :head => {'authorization' => [$CONFIG["twitter"]["username"], $CONFIG["twitter"]["password"]]}
  http.stream do |chunk|
    @tweet_parser << chunk
  end
  http.errback { puts "oops" }
  http.disconnect { puts "oops, dropped connection?" }

  Client.run!({:port => 3000})
end
