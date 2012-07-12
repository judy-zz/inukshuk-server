#!/usr/bin/env ruby
$: << 'lib' << '../lib'

require "eventmachine"
require "em-http-request"
require "em-websocket"
require 'oauth'
require "yajl"
require "yaml"
require 'sinatra/base'
require 'haml'
require 'thin'
require 'json'
require 'net/telnet'
require "active_support/core_ext"
require 'profanity_filter'

require 'client'
require 'arduino'
require 'color'

$CONFIG = YAML.load_file("config.yml")

@arduino = Arduino.new($CONFIG["arduino"]["host"], $CONFIG["arduino"]["port"])

def tweet_received(tweet)
  print "T"
  puts tweet.inspect
  if tweet[:twitter]
    if tweet[:twitter][:text]
      text  = ProfanityFilter::Base.clean(tweet[:twitter][:text], 'hollow')
      user  = (! tweet[:twitter][:user].nil?) ? tweet[:twitter][:user][:screen_name] : "Anonymous"
      color = Color.find_color(tweet[:twitter][:text]) || Color.pseudo_random_rgb
      # puts "Received tweet from #{user}, color #{color}: #{text}"
      @tweet_queue.push(
        :message => {:user => user, :text => text, :color => color, :type => "tweet"}.to_json,
        :color => color
      )
    end
  end
end

def background_received(tweet)
  print "_"
  if tweet[:text]
    text = ProfanityFilter::Base.clean(tweet[:text], 'hollow')
    user = (! tweet[:user].nil?) ? tweet[:user][:screen_name] : "???"
    @background_queue.push(:message => {:user => user, :text => text, :type => "background"}.to_json)
  end
end

# Main run loop
EventMachine.run do
  @background_queue = EM::Queue.new
  @tweet_queue = EM::Queue.new
  @background_parser = Yajl::Parser.new(:symbolize_keys => true)
  @background_parser.on_parse_complete = method(:background_received)
  @tweet_parser = Yajl::Parser.new(:symbolize_keys => true)
  @tweet_parser.on_parse_complete = method(:tweet_received)

  EventMachine::WebSocket.start(:host => "localhost", :port => 7000) do |ws|
    ws.onopen do
      puts "WS: Connection Open"
    end
    EventMachine::PeriodicTimer.new($CONFIG["timing"]["tweets"]) do
      @tweet_queue.pop do |msg|
        ws.send msg[:message].force_encoding('UTF-8')
        @arduino.color = msg[:color]
        @arduino.send_color
      end
    end
    EventMachine::PeriodicTimer.new($CONFIG["timing"]["backgrounds"]) do
      @background_queue.pop do |msg|
        ws.send msg[:message].force_encoding('UTF-8')
      end
    end
    ws.onmessage do |msg|
      puts "WS: Received message: #{msg}"
    end
    ws.onclose do
      puts "WS: Connection Closed"
    end
  end

  twitter_connection = EventMachine::HttpRequest.new('https://stream.twitter.com/1/statuses/filter.json')
  datasift_connection = EventMachine::HttpRequest.new('http://stream.datasift.com/5ddff51e351edca72c2b42224691f82a')

  background_stream = twitter_connection.get(
      :head => {'authorization' => [$CONFIG["twitter"]["username"], $CONFIG["twitter"]["password"]]},
      :query => {:track => $CONFIG["terms"]["backgrounds"]}
    )
  background_stream.stream {|chunk| @background_parser << chunk }
  background_stream.errback {|e| puts "BC: Error: #{e.inspect}" }
  background_stream.disconnect { puts "BC: Dropped" }

  tweet_stream = datasift_connection.get(
      :head => {
        'Authorization' => [$CONFIG["datasift"]["username"], $CONFIG["datasift"]["api_key"]].join(":"),
        'Connection' => "Keep-Alive"
      },
      :timeout => 0
  )
  tweet_stream.stream {|chunk| @tweet_parser << chunk }
  tweet_stream.errback {|e| puts "TC: Error: #{e.inspect}" }
  tweet_stream.disconnect { puts "TC: Dropped" }

  Client.run!({:port => $CONFIG["server"]["port"]})
end
