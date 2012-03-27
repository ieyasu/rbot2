#!/usr/bin/env ruby

require 'nokogiri'

def handle_command(nick, dest, args)
    ff = Nokogiri::HTML(read_url('http://kaction.com/badfanfiction/'))
    s = ff.at('div.shadowbox-inner').inner_text
    s = s[0..s.index('plot device!') + 12].gsub("\n", ' ').gsub('  ', ' ')
    "P\t#{s}"
end

load 'boilerplate.rb'
