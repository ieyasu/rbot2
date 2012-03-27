#!/usr/bin/env ruby

require 'rubybot2/plugin'

register 'PRIVMSG', 'ping'

message_loop do |msg, replier|
  STDERR.puts "got #{msg.inspect}"
  replier.reply msg.text
end
