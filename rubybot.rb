#!/usr/bin/env ruby

require 'rubygems'
require 'rubybot2/irc'

load 'config.rb'

# connect to irc server
# launch subprocess plugins
# event loop

client = IRC::Client.new($rbconfig['host'], $rbconfig['port'])
client.register($rbconfig['nick'], $rbconfig['ircname'])

while (msg = client.read_message)
  # XXX log message received
  p msg

  case msg.command
  when IRC::RPL_WELCOME
    # Request joined channel list as soon as client is accepted
    client.join($rbconfig['join-channels'], $rbconfig['channel-keys'])
    client.send_msg("WHOIS #{$rbconfig['nick']}")
  when IRC::RPL_ENDOFWHOIS
    # time to become oper (if set)
    if (oper = $rbconfig['oper-name']) && oper.length > 0
      client.send_msg("OPER #{oper} #{$rbconfig['oper-passwd']}")
      if (mode = $rbconfig['oper-mode']) =~ /^[a-zA-Z]+$/
        client.send_msg("MODE #{$rbconfig['nick']} +#{mode}")
      end
    end
  when IRC::ERR_NOOPERHOST
    # XXX error becoming oper
  when IRC::CMD_PRIVMSG
    # send to plugins
    puts "privmsg!"
  end
end
