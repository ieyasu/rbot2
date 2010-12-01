#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'open-uri'

def handle_command(nick, dest, args)
    debt = Hpricot(open('http://brillig.com/debt_clock')).at('img')['alt'].gsub(' ', '')
    "P\tUS National Debt is: #{debt}"
end

load 'boilerplate.rb'
