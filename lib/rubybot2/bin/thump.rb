#!/usr/bin/env ruby

def handle_command(nick, dest, args)
    thump = args.length > 0 ? args : 'thump'
    "P\t*#{thump}* *#{thump}* *#{thump}*"
end

load 'boilerplate.rb'
