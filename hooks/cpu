#!/usr/bin/env ruby

def handle_command(nick, dest, args)
  res = `ps -aw -o '%cpu' -o user -o command | grep -v "^ 0.0" | sort -n | tail -1`
  /^\s*(\S+)\s+(\S+)\s+(.*)$/ =~ res
  if $1 == '%CPU'
    "P\tNothing using cpu"
  else
    cmd = $3.length > 50 ? $3[0..50] + '...' : $3
    "P\tmost cpu: #{$1}%, user #{$2}, #{cmd}"
  end
end

load 'boilerplate.rb'
