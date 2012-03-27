#!/usr/bin/env ruby

def handle_command(nick, dest, args)
    unless IRC::channel_name?(dest)
        return "P\tBetter do that in one of my channels"
    end
    unless IRC::channel_name?(args)
        return "P\t#{args} is not a channel name"
    end
    "R\tPART #{args}"
end

load 'boilerplate.rb'
