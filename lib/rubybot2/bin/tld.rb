#!/usr/bin/env ruby

SYNTAX = 'Usage: !tld <tld> | <country name>'

def handle_command(nick, dest, args)
  return "P\t#{SYNTAX}" if args.length == 0 || args =~ /[^a-zA-Z.]/

  result=`grep -i #{args} db/tld.txt`
  if result.length > 0
    result.split(/\r?\n/).map {|l| "P\t#{l.sub(/ /, ' - ')}"}
  else
    "P\t#{args} not found"
  end
end

load 'boilerplate.rb'
