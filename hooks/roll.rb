#!/usr/bin/env ruby

USAGE = "P\tUsage: roll <number of dice>d<faces>[+offset]    example: 3d6"

def handle_command(nick, dest, args)
  return USAGE unless args =~ /(\d+)d(\d+)(?:\s*\+\s*(\d+))?/
  ndice,faces,offset = $1.to_i,$2.to_i,$3.to_i

  return "P\tneed at least 1 dice!" unless ndice > 0
  return "P\tneed at least 1 face!" unless faces > 0
  offset = nil unless offset > 0

  rolls = []
  ndice.times { rolls << rand(faces) + 1 }
  sum = rolls.reduce(:+)

  msg = rolls.join(' ')
  msg += " : #{sum}" if ndice > 1
  msg += " + #{offset} = #{sum + offset}" if offset

  "P\t#{msg}"
end

load 'boilerplate.rb'
