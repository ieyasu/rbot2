#!/usr/bin/env ruby

require 'logger'
require 'open3'
require 'rubybot2/irc'

load 'config.rb'

class Plugin
  def initialize(file)
    @file =  File.basename file

    @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(file)

    # read list of commands to send
    list = []
    while (line = @stdout.gets) and (line = line.chop).length > 0
      list << line.strip
    end
    @commands = /^(?:#{list.join('|')})$/

    @out_thr = Thread.new do
      while (line = @stdout.gets)
        line.strip!
        if IRC.valid_message?(line)
          $log.info "#{@file} <<< #{line}"
          $client.send_msg(line)
        end
      end
    end

    @err_thr = Thread.new do
      while (line = @stderr.gets)
        $log.warn "#{@file} stderr: #{line.chop.inspect}"
      end
    end
  end

  # sends the given IRC message if it matches the list of commands
  def send(msg)
    @stdin.write(msg) if msg.command =~ @commands
  end

  # Close all pipes, kill process with TERM.
  def close
    $log.info "Closing #{@file}"

    Process.kill('INT', @wait_thr.pid) rescue nil

    @stdin.close rescue nil
    @stdout.close rescue nil
    @stderr.close rescue nil

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
    $log.info "#{@file} exit: #{status}"
  end
end

def open_log(file)
  $log = Logger.new(file, $rbconfig['max-log-files'], $rbconfig['max-log-size'])
  $log.level = $rbconfig['log-level']
  log_time_fmt = $rbconfig['log-time-format']
  $log.formatter = proc do |severity, time, prog, msg|
    "#{time.strftime(log_time_fmt)}: #{msg}\n"
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
  $log.info ">>> #{msg}" unless msg.command == IRC::CMD_PING

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
    $log.error "Error becoming oper: #{msg.to_s.inspect}"
  end

  $plugins.each { |plugin| plugin.send(msg) }
end

def quit(what)
  stop_plugins
  $client.quit(what)
  exit(-1)
end

# ---

want_daemon = ARGV.any? { |arg| arg == '-d' }

trap('TERM') { quit('SIGTERM') }
trap('INT')  { quit('SIGINT') } # ^c
trap('HUP')  { restart_plugins }

Process.daemon(true) if want_daemon
open_log(want_daemon ? 'log/rubybot.log' : STDOUT)
start_plugins
connect_client

begin
  while (msg = $client.read_message)
    message_received(msg)
  end
rescue SystemExit
  break # quit called
rescue => e
  bt = e.backtrace.inject('') { |s,t| "#{s}\n  #{t}" }
  $log.error "Caught at top level: #{e.class.name}: #{e.message}#{bt}"
end until $client.closed?

$log.info "Shutting down normally"
