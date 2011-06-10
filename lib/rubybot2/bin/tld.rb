#!/usr/bin/env ruby

SYNTAX = 'Usage: !tld <tld> | <country name>'
MAX_RESULTS = 8

def handle_command(nick, dest, args)
  return "P\t#{SYNTAX}" if args.length == 0 || args =~ /[^a-zA-Z. ]/

  args = ".#{args}" if args =~ /^[a-zA-Z]{2,3}$/
  args = "'#{args.gsub(/\\*\./, "\\\\.")}'"
  if args.length < 3
    return "P\ttld or country name too short"
  end

  result=`grep -i #{args} db/tld.txt`
  if result.length > 0
    ary = result.split(/\r?\n/).map {|l| l.sub(/ /, ' - ')}
    ary = ary[0...MAX_RESULTS] if ary.length > MAX_RESULTS
    "P\t#{ary.join(", ")}"
  else
    "P\t#{args.gsub("\\", '')} not found"
  end
end

load 'boilerplate.rb'
