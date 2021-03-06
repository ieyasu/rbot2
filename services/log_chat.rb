#!/usr/bin/env ruby
# Register for relevant message types and write them to daily chat logs.

require 'rubybot2/plugin'

def logday(t)
  Time.new(t.year, t.month, t.day)
end

def open_logs(t)
  if $logs
    $logs.each_value {|file| file.close}
  end
  $logs = {}

  $rbconfig['join-channels'].split(',').each do |chan|
    dir = "log/#{chan}"
    Dir.mkdir(dir) unless File.directory?(dir)
    $logs[chan] = File.open(t.strftime("log/#{chan}/%Y-%m-%d-#{chan}.log"), 'a+')
  end
  $logday = logday(t)
end

def write_log(chan, log, message)
  unless $rbconfig['no-monitor-channels'].include?(chan)
    log.puts message
    log.flush
  end
end

###

register :echo, IRC::CMD_PRIVMSG, IRC::CMD_JOIN, IRC::CMD_PART, IRC::CMD_NICK, IRC::CMD_TOPIC, IRC::CMD_KICK, IRC::CMD_MODE, IRC::CMD_QUIT

# date older than any current time that will be logged
$logday = Time.new(2000, 1, 1)

message_loop do |msg, replier|
  t = Time.now.utc
  open_logs(t) if $logday < logday(t)

  chan = msg.param(0)
  s = t.strftime("%Y-%m-%dT%H:%M:%SZ ") + # ISO 8601 for great justice!
    case msg.command
    when IRC::CMD_PRIVMSG
      next unless msg.sent_to_channel?
      if msg.text =~ /^\001ACTION .*\001$/
        "* #{msg.nick} #{msg.text[8..-2]}"
      else
        "<#{msg.nick}> #{msg.text}"
      end
    when IRC::CMD_JOIN
      "Join: #{msg.nick}"
    when IRC::CMD_PART
      "Part: #{msg.nick}"
    when IRC::CMD_TOPIC
      "Topic: #{msg.nick} #{msg.text}"
    when IRC::CMD_KICK
      "Kick: #{msg.nick} #{msg.param 1} #{msg.text || '<unk>'}"
    when IRC::CMD_MODE
      next unless IRC.channel_name?(chan)
      "Mode: #{msg.param(2) || chan} #{msg.param 1}"
    when IRC::CMD_NICK
      chan = nil
      "Nick: #{msg.nick} #{msg.text}"
    when IRC::CMD_QUIT
      chan = nil
      "Quit: #{msg.nick} #{msg.text}"
    else
      raise "Unexpected message: #{msg}"
    end

  if chan
    write_log(chan, $logs[chan], s)
  else
    $logs.each {|chan, log| write_log(chan, log, s) }
  end
end
