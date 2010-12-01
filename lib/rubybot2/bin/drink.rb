#!/usr/bin/env ruby

SYNTAX = 'Usage: !drink <drink-name>'
BASE_URL = 'http://www.webtender.com'

def parse_body(body)
    i = body.index(/<h1/i) or return
    j = body.index(/<\/h1/i, i) or return
    name = strip_html(body[i...j])

    i = body.index('Ingredients:') or return
    i = body.index(/<ul/i, i) or return
    j = body.index(/<\/ul/i, i) or return
    ingredients = body[i...j].scan(/<li>[^\n]+/i).map {|h| strip_html(h)}

    i = body.index('Mixing instructions:', j) or return
    i = body.index(/<p/i, i) or return
    j = body.index(/<\/p/i, i) or return
    instructions = strip_html(body[i...j])

    ["P\t#{name}"] + ingredients.map {|ing| "P\t#{ing}"} +
        ["P\t#{instructions}"]
end

def find_first_result(body)
    return unless body.index('Quicksearch results')

    i = body.index('<!--drstart-->') or return

    body.index(/<A\s+HREF=['"]?([^'"> ]+)['"]?/i, i) or return
    BASE_URL + $1
end

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" unless args.length > 0
    body = open(BASE_URL + '/cgi-bin/search?verbose=on&' <<
                "name=#{CGI.escape(args)}").read
    if body
        if (url = find_first_result(body))
            body = open(url).read
        else
            return "P\terror getting first search result for #{args}"
        end
        (body && parse_body(body)) || "P\terror parsing recipe for #{args}"
    else
        "P\terror accessing webtender.com"
    end
end

load 'boilerplate.rb'
