#!/usr/bin/env ruby

STDOUT.sync = true # don't need to call flush

# list of commands to receive"
puts "PRIVMSG"
puts "PING"
puts
#STDOUT.flush

loop do
  sleep 2
  puts "Time is now #{Time.now}"
  #STDOUT.flush
  sleep 3
  STDERR.puts "errmsg"
end
