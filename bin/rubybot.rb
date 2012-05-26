#!/usr/bin/env ruby

require 'logger'
require 'open3'
require 'rubybot2/irc'

load 'config.rb'

RB_PID = 'run/rubybot.pid'
SERVICE_CHECK_TIMEOUT = 5 * 60 + 3

class Service
  attr_reader :file

  def initialize(file)
    @file =  File.basename file

    @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(ENV, file)

    # see if it wants echoes
    if (line = @stdout.gets)
      @wants_echoes = (line =~ /^echo$/) != nil
    else
      raise "#{line.inspect} received for wants_echoes line"
    end

    # read list of commands to send
    if (line = @stdout.gets)
      list = line.split(/\s+/)
      @commands = list.length > 0 ? /^(?:#{list.join('|')})$/ : /(?!)/
    else
      raise "#{line.inspect} received for commands line"
    end

    @out_thr = Thread.new do
      while (line = @stdout.gets)
        line.strip!
        begin
          $client.send_msg(line)
          $log.info "#{@file} <<< #{line}"
        rescue ArgumentError
          $log.warn "Invalid message from #{@file}: #{line.inspect}"
        end
      end
    end

    @err_thr = Thread.new do
      while (line = @stderr.gets)
        $log.warn "#{@file}: #{line.chop}"
      end
    end

    record_pid(pidfile, @wait_thr.pid)

    $log.info "Started #{@file} #{@commands.inspect}"
  end

  # sends the given IRC message if it matches the list of commands
  def send(msg, is_echo = nil)
    if msg.command =~ @commands && (is_echo.nil? || @wants_echoes)
      @stdin.puts(msg)
    end
  rescue IOError
    # When we kill Rubybot, need to catch this except to prevent infinite loop non-exit
  end

  # Checks subprocess for life
  def alive?
    @wait_thr.alive?
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
    delete_pid(pidfile)
    status = @wait_thr.value # join and return exit status
    $log.info "#{@file} exit: #{status}"
  end

  private

  def pidfile
    "run/#{File.basename @file, '.rb'}.pid"
  end
end

class RubyBot2 < IRC::Client
  def send_msg(line)
    super(line)
    msg = IRC.parse_message(":#{$rbconfig['nick']} #{line}")
    $services.each { |service| service.send(msg, :echo) }
  end
end

def record_pid(file, pid)
  File.open(file, 'w') { |fout| fout.puts pid }
end

def delete_pid(file)
  File.delete(file) if File.exist?(file)
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
  $client = RubyBot2.new($rbconfig['host'], $rbconfig['port'])
  $client.register($rbconfig['nick'], $rbconfig['ircname'])
end

def start_services
  $services = []

  Dir.glob('services/*').sort.each do |file|
    s = File.stat(file)
    if s.file? and s.executable?
      begin
        $services << Service.new(file)
      rescue => e
        $log.error "Error starting #{file}: #{e.message}"
      end
    end
  end

  # watcher thread cleans up dead services
  Thread.new do
    loop do
      sleep SERVICE_CHECK_TIMEOUT
      $services.delete_if do |service|
        if service.alive?
          false
        else
          e = "Service #{service.file} quit unexpectedly"
          $log.error e
          $client.privmsg($rbconfig['join-channels'], e)
          service.close
          sleep(0.5)
          service.shutdown
          true
        end
      end
    end
  end
end

def stop_services
  $services.each { |service| service.close }
  sleep(0.5)
  $services.each { |service| service.shutdown }
end

def restart_services
  stop_services
  start_services
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

  $services.each { |service| service.send(msg) }
end

def quit(what)
  stop_services
  $client.quit(what)
  exit(-1)
end

# ---

want_daemon = ARGV.any? { |arg| arg == '-d' }

trap('TERM') { quit('SIGTERM') }
trap('INT')  { quit('SIGINT') } # ^c
trap('HUP')  { restart_services }

if want_daemon
  Process.daemon(true)
  record_pid RB_PID, Process.pid
end
open_log(want_daemon ? 'log/rubybot.log' : STDOUT)
start_services
connect_client

begin
  while (msg = $client.read_message)
    message_received(msg)
  end
  sleep 1
rescue SystemExit
  break # quit called
rescue => e
  bt = e.backtrace.inject('') { |s,t| "#{s}\n  #{t}" }
  $log.error "Caught at top level: #{e.class.name}: #{e.message}#{bt}"
end until $client.closed?

$log.info "Shutting down normally"

delete_pid(RB_PID)
