#!/usr/bin/env ruby

SYNTAX = 'Usage: !update'

def handle_command(nick, dest, args)
  git = `git pull origin HEAD`
  out = ''
  git.each_line { |line| out << "P\t#{line.strip}\n" }
  out
end

load 'boilerplate.rb'
