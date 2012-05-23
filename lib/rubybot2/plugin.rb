require 'rubygems'
require 'rubybot2/irc'
require 'rubybot2/replier'

load 'config.rb'

trap('INT') { exit(0) }

# List of IRC messages this plugin wants to receive.
def register(*messages)
  if messages.first == :echo
    puts 'echo'
    messages.shift
  else
    puts
  end
  puts messages.join(' ')
end

# Given an exception, prints nicely formatted reporting information to STDERR.
def report_exception(e, task = 'checking jobs')
  bt = e.backtrace.inject('') { |s,t| "#{s}\n  #{t}" }
  STDERR.puts "Caught exception #{e.class} #{task}: #{e.message} #{bt}"
end

# Wait for input, parse incoming messages, and yield with an IRC message
# and replier.
def message_loop
  while (line = STDIN.gets)
    msg = IRC.parse_message(line)
    replier = Replier.new msg
    begin
      yield msg, replier
    rescue => e
      report_exception e, 'from message loop block'
    end
  end
end
