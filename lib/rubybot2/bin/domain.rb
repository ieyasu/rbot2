#!/usr/bin/env ruby

require 'shellwords'

def handle_command(nick, dest, args)
  resp = `whois -H -F '#{Shellwords.shellescape args}'`

  if resp =~ /^\s*Expiration Date:\s*(.*)/
    "P\t#{args} expires #{$1}"
  elsif resp =~ /No match for/ or resp =~ /No.*this kind of object/
    "P\t#{args} not found"
  else
    "P\tParse error in whois response for #{args}"
  end
end

load 'boilerplate.rb'
