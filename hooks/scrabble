#!/usr/bin/env ruby

USAGE = "P\tUsage: scrabble <word>"

def handle_command(nick, dest, args)
  scrab_word = args.strip.upcase
  return USAGE unless scrab_word.length > 0

  File.open("db/scrabbledict.txt") do |fin|
    while (line = fin.gets)
      if scrab_word == line.split(' :').first
        return "P\t#{args} is valid"
      end
    end
  end

  "P\t#{args} is invalid"
end

load 'boilerplate.rb'
