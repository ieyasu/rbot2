#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'json'

def handle_command(nick, dest, args)
  data = JSON.parse(open("https://mtgox.com/code/data/ticker.php").read)['ticker']
  "P\tMt. Gox: $#{data['last']} (high: $#{data['high']}, low: $#{data['low']})"
end

load 'boilerplate.rb'
