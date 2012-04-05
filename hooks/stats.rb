#!/usr/bin/env ruby
# D&D stats generator

# roll 4 6-sided dice, drop the lowest number, return the sum of the rest
def roll4d6max3
  rolls = []
  4.times { rolls << rand(6) + 1 }
  rolls.sort[1..-1].inject(0, &:+)
end

def handle_command(nick, dest, args)
  s = "P\tYour stats are"
  6.times { s << " #{roll4d6max3}" }
  s
end

load 'boilerplate.rb'
