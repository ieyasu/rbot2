#!/usr/bin/env ruby
# Listens channel and private messages to the bot which instruct it
# to run a command.  There are three different command interfaces:
# internal, implemented as ruby code under commands/; normal commands
# implemented as exec()able scripts under bin/; and php web commands
# accessed by http (see php-root config value).

require 'rubybot2/plugin'
require 'rubybot2/thread_janitor'
require 'rubybot2/db'
require 'open3'

def file_to_class(filename)
    File.basename(filename) =~ /(\w+)\.rb$/
    s = $1.gsub(/(?:\A|_|-)[a-z]/) { |m| m[-1,1].upcase }
    Module.const_get(s.to_sym)
end

def load_commands(path)
  path =~ %r!commands/(.+)!
  chan = $1 || ''
  Dir.foreach(path) do |fn|
    file = "#{path}/#{fn}"
    if (File.file?(file) || File.symlink?(file)) && fn =~ /(\w+)\.rb$/
      STDERR.puts "Loading command #{fn}"
      load file
      cmd = file_to_class(fn).new(@client)
      ($commands[chan] ||= []) << cmd
    elsif File.directory?(fn) && IRC::channel_name?(fn)
      load_command_directory(path)
    end
  end
end

def run_command(command, args, msg, replier)
  cmdsym = "c_#{command}".to_sym
  if (cmd = find_command(cmdsym, msg.dest))
    cmd.send(cmdsym, msg, args, replier)
  elsif (bin = find_bin(command, msg.dest))
    run_bin(bin, msg, args, replier)
  end
rescue Exception => e
  report_exception e
end

def find_command(cmdsym, dest)
  (($commands[dest] || []) + $commands['']).find do |cmd|
    cmd.respond_to?(cmdsym) ? cmd : nil
  end
end

def find_bin(command, dest)
  path = "run/bin/#{command}"
  path if executable?(path)
end

def executable?(path)
  if File.executable?(path)
    true unless File.directory?(path)
  elsif File.exists?(path)
    STDERR.puts "#{path} isn't executable"
  end
end

def run_bin(bin, msg, args, r)
  args ||= ''
  zip = Account.zip_by_nick(msg.nick) || $rbconfig['default-zip']
  ENV['ZIP'] = zip.to_s
  Open3.popen3(bin, msg.nick, msg.dest, args) do |b_in, b_out, b_err|
    while (line = b_out.gets)
      line = line.rstrip
      r.raw("#{line}\r\n") if line.length > 0
    end
    while (line = b_err.gets)
      line = line.rstrip
      r.reply(line) if line.length > 0
    end
  end
end

# ---

register  IRC::CMD_PRIVMSG

$commands = {}
load_commands('lib/rubybot2/commands')
$janitor = ThreadJanitor.new

message_loop do |msg, replier|
  next unless msg.text =~ /^(#{$rbconfig['cmd_prefix']})?([^\/\s]+)\s*(.*)$/
  pfx,command,args = $1,$2,$3
  command = command.downcase

  # do not respond to public command words without a command prefix
  next if msg.sent_to_channel? && !pfx

  # ensure that commands which should be privately messaged
  # only are in fact privately messaged
  msg_only = $rbconfig['msg-commands'].member?(command)
  if msg_only && msg.sent_to_channel?
    r.priv_reply("Try: /msg #{$rbconfig['nick']} #{msg.text[1..-1]}")
    next
  end

  $janitor.register(Thread.new { run_command(command, args, msg, replier) })
end
