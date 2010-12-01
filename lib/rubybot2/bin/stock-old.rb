#!/usr/bin/env ruby

SYNTAX = 'Usage: !stock <symbol>'

def parse_quote(body, symbol)
    i = j = nil
    if (i = body.index(/<b>\s*#{symbol}/i))
        j = body.index('</font', i)
    elsif (i = body.index(/class=l>\s*#{symbol}/i))
        j = body.index('</a>', i)
    end
    return 'Stock quote not found' unless i && j
    company = strip_html(body[i...j])

    i = body.index('<td colspan=3 nowrap>', j) or return
    j = body.index('</td>', j) or return
    stats = strip_html(body[i...j])

    "#{company} #{stats}"
end

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" if args.length == 0

    body = open("http://www.google.com/search?hl=en&q=stock%3A#{CGI.escape(args)}&btnG=Google+Search").read
    if (quote = parse_quote(body, args))
        "P\t#{quote}"
    else
        "P\terror parsing quote for #{args}"
    end
end

load 'boilerplate.rb'
