#!/usr/bin/env ruby

SYNTAX = 'Usage: !filetype <extension>'

def parse_fileinfo(body, ext)
    return if body.index('Not Found')

    i = body.index(/table\s+class="results"/i) or return
    i = body.index('File Type', i) or return
    i = body.index('<td', i) or return
    j = body.index('</td>', i) or return
    type = strip_html(body[i...j])
    i = body.index('File Description', j) or return
    i = body.index('<td', i) or return
    j = body.index('</td>', i) or return
    descr = strip_html(body[i...j])
    "P\t#{ext}: #{type} -- #{descr}"
end

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" if args.length == 0

    i = args.rindex('.')
    args = args[i+1..-1] if i
    if args =~ /([a-zA-Z0-9$\#@!_~\-]+)/
        ext = $1
        body = open("http://fileinfo.net/extension/#{ext}").read
        parse_fileinfo(body, ext)
    else
        "P\tbad file extension '#{args}'; legal characters are a-zA-Z0-9$\#@!_~-"
    end
end

load 'boilerplate.rb'
