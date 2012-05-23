#!/usr/bin/env ruby
# Register for relevant message types and write them to daily chat logs.

require 'rubybot2/plugin'

def logday(t)
  t.year * 366 + t.month * 31 + t.day
end

def open_logs(t)
  if $logs
    $logs.each_value {|file| file.close}
  end
  $logs = {}

  $rbconfig['join-channels'].split(',').each do |chan|
    dir = "log/#{chan}"
    Dir.mkdir(dir) unless File.directory?(dir)
    $logs[chan] = File.open(t.strftime("log/#{chan}/%Y-%m-%d.log"), 'a+')
  end
  $logday = logday(t)
end

###

register IRC::CMD_PRIVMSG, IRC::CMD_JOIN, IRC::CMD_PART, IRC::CMD_NICK, IRC::CMD_TOPIC, IRC::CMD_KICK, IRC::CMD_MODE, IRC::CMD_QUIT

$logday = -1

message_loop do |msg, replier|
  t = Time.now.utc
  open_logs(t) if $logday < logday(t)

  chan = msg.param(0)
  s = t.strftime("%Y-%m-%dT%H:%M:%SZ ") +
    case msg.command
    when IRC::CMD_PRIVMSG
      if msg.text =~ /^\001ACTION .*\001$/
        "#{msg.dest} * #{msg.nick} #{msg.text[8..-2]}"
      else
        "#{msg.dest} <#{msg.nick}> #{msg.text}"
      end
    when IRC::CMD_JOIN
      "#{msg.text} Join: #{msg.nick}"
    when IRC::CMD_PART
      "#{msg.text} Part: #{msg.nick}"
    when IRC::CMD_NICK
      chan = nil
      "Nick: #{msg.nick} #{msg.text}"
    when IRC::CMD_TOPIC
      "#{msg.param 0} Topic: #{msg.nick} #{msg.text}"
    when IRC::CMD_KICK
      "#{msg.param 0} Kick: #{msg.nick} #{msg.param 1} #{msg.text || '<unk>'}"
    when IRC::CMD_MODE
      next unless IRC.channel_name?(chan)
      "#{chan} Mode: #{msg.param 2} #{msg.param 1}"
    when IRC::CMD_QUIT
      chan = nil
      "Quit: #{msg.nick} #{msg.text}"
    else
      raise "Unexpected message: #{msg}"
    end

  if chan
    $logs[chan].puts s
    $logs[chan].flush
  else
    $logs.each do |chan, log|
      next if $rbconfig['no-monitor-channels'].include?(chan)
      log.puts s
      log.flush
    end
  end
end
