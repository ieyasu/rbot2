#!/usr/bin/env ruby

require 'socket'

SYNTAX = 'Usage: !arin <ip address range>'

def arin_lookup(args)
    sock = TCPSocket.open('whois.arin.net', 43)
    sock.puts args
    infos = {}
    while (line = sock.gets)
        case line
        when /^OrgName:\s*(.+)/
            infos[:org] = $1
        when /^NetRange:\s*(.+)/
            infos[:range] = $1
        when /^NameServer:\s*(.+)/
            (infos[:ns] ||= []) << $1.downcase
        end
    end
    sock.close
    infos
end

def handle_command(nick, dest, args)
    if args.length == 0
        "P\t#{SYNTAX}"
    elsif (infos = arin_lookup(args)) && infos[:range]
        s = "P\t#{infos[:range]}: #{infos[:org]}"
        s << " (NS #{infos[:ns].join(', ')})" if infos[:ns]
        s
    else
        "P\tNo match for '#{args}'"
    end
end

load 'boilerplate.rb'
