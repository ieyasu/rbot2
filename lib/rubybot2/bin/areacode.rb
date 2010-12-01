#!/usr/bin/env ruby

SYNTAX = 'Usage: !areacode <code> | <location>'

MAX_LINES = 9

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" unless args.length > 0

    reply = []
    match = Regexp.new(args, Regexp::IGNORECASE)
    File.open('db/area_codes') { |fin|
        fin.each { |line|
            reply << "P\t#{line}" if line =~ match
        }
    }
    if reply.length > 0
        if reply.length > MAX_LINES
            reply[0...MAX_LINES / 2].join +
                "P\tRemaining #{reply.length - MAX_LINES / 2} results ignored"
        else
            reply.join
        end
    elsif args =~ /^\d{3}$/
        "P\tUnknown areacode #{args}"
    else
        "P\tNo areacode for #{args}"
    end
end

load 'boilerplate.rb'
