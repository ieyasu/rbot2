#!/usr/bin/env ruby

def handle_command(nick, dest, args)
  "P\t#{`apg -a 0 -n 6 -M SNCL -m 8 -x 14`.gsub(/\n/, ' ').strip}"
end

load 'boilerplate.rb'
