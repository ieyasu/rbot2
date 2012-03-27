#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

def handle_command(nick, dest, args)
    doc = Nokogiri::HTML(open('http://brillig.com/debt_clock').read)
    debt = doc.xpath('//img').first[:alt].gsub(/\s/, '')
    "P\tUS National Debt is: #{debt}"
end

load 'boilerplate.rb'