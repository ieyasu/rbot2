#!/usr/bin/env ruby

require 'nokogiri'

def handle_command(nick, dest, args)
    doc = Nokogiri::HTML(read_url('http://brillig.com/debt_clock'))
    debt = doc.xpath('//img').first[:alt].gsub(/\s/, '')
    "P\tUS National Debt is: #{debt}"
end

load 'boilerplate.rb'
