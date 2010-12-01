#!/usr/bin/env ruby

def handle_command(nick, dest, args)
    "R\tMODE #{dest} -o #{nick}" if IRC::channel_name?(dest)
end

load 'boilerplate.rb'
