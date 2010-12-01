#!/usr/bin/env ruby

SYNTAX = 'Usage: !image <search terms>'

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" if args.length == 0

    body = open("http://images.google.com/images\?q=#{CGI.escape(args)}\&ie=UTF-8\&oe=UTF-8\&hl=en").read
    if body.index(/<a href=\/imgres\?imgurl=([^&]+)/)
        "P\t#{$1}"
    else
        "P\tno image was found for #{args}"
    end
end

load 'boilerplate.rb'
