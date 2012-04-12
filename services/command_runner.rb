#!/usr/bin/env ruby
# Listens channel and private messages to the bot which instruct it
# to run a command.  There are three different command interfaces:
# internal, implemented as ruby code under plugins/; normal commands
# implemented as exec()able scripts under bin/; and php web commands
# accessed by http (see php-root config value).

require 'rubybot2/plugin'
require 'rubybot2/thread_janitor'
require 'rubybot2/db'
require 'open3'

RUN_RUBY = 'lib/rubybot2/run_ruby.rb'

def open_log(file)
  $log = Logger.new(file, $rbconfig['max-log-files'], $rbconfig['max-log-size'])
  $log.level = $rbconfig['log-level']
  log_time_fmt = $rbconfig['log-time-format']
  $log.formatter = proc do |severity, time, prog, msg|
    "#{time.strftime(log_time_fmt)}: #{msg}\n"
  end
end

def file_to_class(filename)
  File.basename(filename) =~ /(\w+)\.rb$/
  s = $1.gsub(/(?:\A|_|-)[a-z]/) { |m| m[-1,1].upcase }
  Module.const_get(s.to_sym)
end

def load_plugins(path)
  path =~ %r!plugins/(.+)!
  chan = $1 || ''
  Dir.foreach(path) do |fn|
    file = "#{path}/#{fn}"
    if (File.file?(file) || File.symlink?(file)) && fn =~ /(\w+)\.rb$/
      STDERR.puts "Loading command #{fn}"
      load file
      cmd = file_to_class(fn).new(@client)
      ($plugins[chan] ||= []) << cmd
    elsif File.directory?(fn) && IRC::channel_name?(fn)
      load_hook_directory(path)
    end
  end
end

def run_hook(command, args, msg, replier)
  zip = Account.zip_by_nick(msg.nick) || $rbconfig['default-zip']
  ENV['ZIP'] = zip.to_s

  cmdsym = "c_#{command}".to_sym
  if (cmd = find_hook(cmdsym, msg.dest))
    $log.info "Running internal command #{command} for #{msg.nick}"
    cmd.send(cmdsym, msg, args, replier)
  elsif (rb = find_rb(command))
    $log.info "Running ruby hook #{command} for #{msg.nick}"
    Open3.popen3(RUN_RUBY, rb, command, args, msg.full_message) do |_, out, err|
      process_hook_output(replier, out, err)
    end
  elsif (bin = find_bin(command))
    $log.info "Running generic hook #{command} for #{msg.nick}"
    Open3.popen3(bin, msg.nick, msg.dest, args || '') do |_, out, err|
      process_hook_output(replier, out, err)
    end
  elsif not msg.sent_to_channel? and command =~ /^\d/
    $log.info "Reinterpreting text as calc hook"
    run_hook('calc', msg.text, msg, replier) # looks like math
  else
    $log.info "Saw non-existent hook #{command} from #{msg.nick}"
  end
rescue Exception => e
  report_exception e
end

def find_hook(cmdsym, dest)
  (($plugins[dest] || []) + $plugins['']).find do |cmd|
    cmd.respond_to?(cmdsym) ? cmd : nil
  end
end

def find_rb(command)
  path = "hooks/#{command}.rb"
  path if File.exist?(path)
end

def find_bin(command)
  path = "hooks/#{command}"
  path if executable?(path)
end

def executable?(path)
  if File.executable?(path)
    true unless File.directory?(path)
  elsif File.exists?(path)
    STDERR.puts "#{path} isn't executable"
  end
end

def process_hook_output(r, out, err)
  while (line = out.gets)
    line = line.rstrip
    r.raw("#{line}\r\n") if line.length > 0
  end
  while (line = err.gets)
    line = line.rstrip
    r.reply(line) if line.length > 0
  end
end

def check_message(msg, replier)
  return unless msg.text =~ /^(#{$rbconfig['cmd_prefix']})?([^\/\s]+)\s*(.*)$/
  pfx,command,args = $1,$2,$3
  command = command.downcase

  # do not respond to public command words without a command prefix
  return if msg.sent_to_channel? && !pfx

  # ensure that commands which should be privately messaged
  # only are in fact privately messaged
  msg_only = $rbconfig['msg-commands'].member?(command)
  if msg_only && msg.sent_to_channel?
    r.priv_reply("Try: /msg #{$rbconfig['nick']} #{msg.text[1..-1]}")
    return
  end

  Thread.new { run_hook(command, args, msg, replier) }
end

# ---

register  IRC::CMD_PRIVMSG

open_log('log/command_runner.log')

$plugins = {}
load_plugins('plugins')
$janitor = ThreadJanitor.new
message_loop do |msg, replier|
  t = check_message(msg, replier) and $janitor.register(t)
end
