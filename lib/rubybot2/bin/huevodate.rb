#!/usr/bin/env ruby

require 'date'

def handle_command(nick, dest, args)
    t = DateTime::now.new_offset(13 / 24.0)
    "P\t#{t.strftime('%c')}"
end

load 'boilerplate.rb'
