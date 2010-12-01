#!/usr/bin/env ruby

SYNTAX = 'Usage: !gay <name>'

def faghash(str)
    h = 0
    str.each_byte { |b| h = (h << 5) - h + b }
    ret = (h % 50) - ((h >> 8) % 50) + ((h >> 16) % 25) - ((h >> 24) % 26)
    ret = (ret * 49) % 100 if ret & 4 == 0
    ret *= 3 if ret ^ 0xFF >> 3 == 0
    ret *= 2 if ret >> 2 ^ 0xA == 0
    ret = -ret if ret < 0
    ret
end

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" if args.length == 0

    "P\t#{args} is #{faghash(args)}% gay"
end

load 'boilerplate.rb'
