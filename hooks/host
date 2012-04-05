#!/usr/bin/env ruby

require 'socket'

SYNTAX = 'Usage: !host <hostname> | <ip address>'

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" unless args.length > 0

    if args =~ /^\d+\.\d+\.\d+\.\d+$/
        addr = args.split('.').map {|i| i.to_i}.pack('CCCC')
        ary = Socket::gethostbyaddr(addr)
        "P\t#{args} points to #{ary[0]}"
    else
        ary = Socket::gethostbyname(args)
        ipaddr = (0..3).map {|i| ary[3][i] }.join('.')
        "P\t#{args} has address #{ipaddr}"
    end
rescue SocketError => e
    if e.message =~ / not (?:found|known)/i
        "P\thost #{args} not found"
    else
        raise e
    end
end

load 'boilerplate.rb'
