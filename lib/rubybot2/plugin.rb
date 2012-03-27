require 'rubygems'
require 'rubybot2/irc'
require 'rubybot2/replier'

load 'config.rb'

trap('INT') { exit(0) }

# List of IRC messages this plugin wants to receive.
def register(*messages)
  messages.each { |msg| puts msg }
  puts
end

# Wait for input, parse incoming messages, and yield with an IRC message
# and replier.
def message_loop
  while (line = STDIN.gets)
    msg = IRC.parse_message(line)
    replier = Replier.new msg
    yield msg, replier
  end
end

# Given an exception, prints nicely formatted reporting information to STDERR.
def report_exception(e)
  bt = e.backtrace.inject('') { |s,t| "#{s}\n  #{t}" }
  STDERR.puts "Caught exception #{e.class} checking jobs: #{e.message} #{bt}"
end
