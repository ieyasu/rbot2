#!/usr/bin/env ruby

MAX_OUTPUT_SIZE = 1000
LINE_SIZE = 480

def parse_etymology(body, i)
    j = body.index('Etymology:', i) or raise ''
    k = body.index('<br', j) or raise ''
    ety = strip_html(body[j...k])
    return " || #{ety}", k
rescue RuntimeError
    return '', i
end

def parse_definitions(body)
    i = body.index('Main Entry:') or return
    i = body.index('<b', i) or return
    j = body.index('</b', i) or return
    word = strip_html(body[i...j].
        gsub(/<sup[^>]*>[^<]*<\/sup[^>]*>/i, '').
        gsub("\267", ''))

    i = body.index('Function:', i) or return
    i = body.index('<i', i) or return
    j = body.index('</i', i) or return
    fnctn = strip_html(body[i...j])

    ety, j = parse_etymology(body, j)

    i = body.index(/\r?\n/, j) or return
    i += $~[0].length
    j = body.index(/\r?\n/, i) or return
    if (k = body.index('<br>-', i))
        j = k
    end
    defs = strip_html(body[i...j]).gsub(' :', ':')

    "#{word} (#{fnctn}) #{defs}#{ety}"
end

def handle_command(nick, dest, args)
    return "P\tUsage: !dict <word>" unless args.length > 0

    body = read_url("http://www.m-w.com/dictionary/#{CGI.escape(args)}")
    if (repl = parse_definitions(body))
        "P\t#{repl}"
    else
        "P\t#{args} not found"
    end
end

load 'boilerplate.rb'
