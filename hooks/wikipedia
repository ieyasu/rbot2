#!/usr/bin/env ruby

require 'cgi'
require 'net/http'
require 'uri'

SYNTAX = 'Usage: !wp <search terms>'

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" unless args.length > 0

    resp = Net::HTTP.get_response(URI.parse(
    "http://en.wikipedia.org/wiki/Special:Search?search=#{CGI.escape(args)}"))

    (resp && resp['location']) ?
        "P\t#{resp['location']}" :
        "P\tcouldn't find wikipedia page for '#{args}'"
rescue Exception => e
    "P\terror accessing wikipedia (#{e.message})"
end

load 'boilerplate.rb'
