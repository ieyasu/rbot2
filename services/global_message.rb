#!/usr/bin/env ruby
# Joins the IRC channels listed in the config and listens for channel chat
# from nicks that need to be delivered 'nexts' and records the last thing
# said by each nick.

require 'rubybot2/plugin'
require 'rubybot2/nextlib'

register IRC::CMD_PRIVMSG

message_loop do |msg, replier|
  next unless msg.sent_to_channel?

  # update last statement
  unless $rbconfig['no-monitor-channels'].include?(msg.dest)
    DB['INSERT OR REPLACE INTO last VALUES(?, ?, ?, ?);',
    msg.nick, msg.dest, msg.text, Time.now.to_i].all
  end

  # check for nexts
  NextLib.read(msg.nick, replier)
end
