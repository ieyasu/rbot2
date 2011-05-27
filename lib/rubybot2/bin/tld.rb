#!/usr/bin/env ruby

SYNTAX = 'Usage: !tld <tld> | <country name>'

def handle_command(nick, dest, args)
  return "P\t#{SYNTAX}" if args.length < 2 || args =~ /[^a-zA-Z.]/

  args = ".#{args}" if args =~ /^[a-zA-Z]{2,3}$/
  args = args.gsub(/\\*\./, "\\\\\\.")

  result=`grep -i #{args} db/tld.txt`
  if result.length > 0
    "P\t#{result.split(/\r?\n/).map {|l| l.sub(/ /, ' - ')}.join(", ")}"
  else
    "P\t#{args.gsub("\\", '')} not found"
  end
end

load 'boilerplate.rb'
