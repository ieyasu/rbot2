#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

def handle_command(nick, dest, args)
    ff = Nokogiri::HTML(open('http://kaction.com/badfanfiction/').read)
    s = ff.at('div.shadowbox-inner').inner_text
    s = s[0..s.index('plot device!') + 12].gsub("\n", ' ').gsub('  ', ' ')
    "P\t#{s}"
end

load 'boilerplate.rb'
