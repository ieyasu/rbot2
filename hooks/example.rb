#!/usr/bin/env ruby

SYNTAX = 'Usage: !example <args>'

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" if args.length == 0

  ["P\thello world", "P\tyou said '#{args}'", "P\tyour zip is #{ENV['ZIP']}"]
end

load 'boilerplate.rb'
