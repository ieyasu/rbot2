#!/usr/bin/env ruby

require 'open3'
require 'rubybot2/irc'

load 'config.rb'

class Plugin
  def initialize(file)
    @file =  file
    @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(file)

    # read list of commands to send
    list = []
    while (line = @stdout.gets) and (line = line.chop).length > 0
      list << line.strip
    end
    @commands = /^(?:#{list.join('|')})$/

    @out_thr = Thread.new do
      while (line = @stdout.gets)
        # XXX feed to irc if valid message
        STDOUT.puts "stdout from #{file}: #{line}"
      end
      puts "exiting out reader"
    end

    @err_thr = Thread.new do
      while (line = @stderr.gets)
        # XXX log stdout
        STDERR.puts "stderr from #{file}: #{line}"
      end
      puts "exiting err reader"
    end
  end

  # sends the given IRC message if it matches the list of commands
  def send(msg)
    @stdin.puts(msg) if msg.command =~ @commands
  end

  # Close all pipes, kill process with TERM.
  def close
    puts "Closing #{@file}"
    Process.kill('INT', @wait_thr.pid) rescue nil

    @stdin.close
    @stdout.close
    @stderr.close

    @out_thr.join
    @err_thr.join
  end

  # Forcibly exit process if necessary, print exit status.
  def shutdown
    begin
      unless Process.waitpid(@wait_thr.pid, Process::WNOHANG)
        Process.kill('KILL', @wait_thr.pid)
      end
    rescue Errno::ECHILD # process already exited, swallow error
    end
    status = @wait_thr.value # join and return exit status
    puts "#{@file} exit: #{status}"
  end
end

def connect_client
  $client = IRC::Client.new($rbconfig['host'], $rbconfig['port'])
  $client.register($rbconfig['nick'], $rbconfig['ircname'])
end

def start_plugins
  $plugins = []

  Dir.glob('plugins/*').sort.each do |file|
    s = File.stat(file)
    if s.file? and s.executable?
      $plugins << Plugin.new(file)
      puts "Started #{file}"
    end
  end
end

def stop_plugins
  $plugins.each { |plugin| plugin.close }
  sleep(0.5)
  $plugins.each { |plugin| plugin.shutdown }
end

def restart_plugins
  stop_plugins
  start_plugins
end

def message_received(msg)
  # XXX log message received
  p msg unless msg.command == IRC::CMD_PING

  case msg.command
  when IRC::RPL_WELCOME
    # Request joined channel list as soon as client is accepted
    $client.join($rbconfig['join-channels'], $rbconfig['channel-keys'])
    $client.send_msg("WHOIS #{$rbconfig['nick']}")
  when IRC::RPL_ENDOFWHOIS
    # time to become oper (if set)
    if (oper = $rbconfig['oper-name']) && oper.length > 0
      $client.send_msg("OPER #{oper} #{$rbconfig['oper-passwd']}")
      if (mode = $rbconfig['oper-mode']) =~ /^[a-zA-Z]+$/
        $client.send_msg("MODE #{$rbconfig['nick']} +#{mode}")
      end
    end
  when IRC::ERR_NOOPERHOST
    # XXX error becoming oper
  end

  $plugins.each { |plugin| plugin.send(msg) }
end

def quit(what)
  stop_plugins
  $client.quit(what)
  exit(-1)
end

# ---

trap('TERM') { quit('SIGTERM') }
trap('INT')  { quit('SIGINT') } # ^c
trap('HUP')  { restart_plugins }

connect_client
start_plugins

begin
  while (msg = $client.read_message)
    message_received(msg)
  end
rescue IRC::MessageParseError => e
  # XXX log exception
  p e
rescue SystemExit
  break # quit called
end until $client.closed?

puts "Rubybot shutting down normally"
