#!/usr/bin/env ruby

require 'rubygems'
require 'raspell'

SYNTAX = 'Usage: !spell <word>'

def google_suggest(args)
    body = open("http://www.google.com/search?lr=lang_en&q=#{CGI.escape args}").read
    i = body.index('Did you mean') or return []
    i = body.index('<i>', i) or return []
    j = body.index('</i>', i) or return []
    strip_html(body[i...j])
end

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" unless args.length > 0

    spell = Aspell.new
    if spell.check(args)
        "P\t#{args} is spelled correctly"
    else
        sugg = spell.suggest(args).join(', ') || google_suggest(args)
        "P\t#{args} is misspelled; suggestions: #{sugg}"
    end
end

load 'boilerplate.rb'
