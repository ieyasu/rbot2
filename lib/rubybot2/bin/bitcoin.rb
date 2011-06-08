#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'json'

def handle_command(nick, dest, args)
  data = JSON.parse(open("https://mtgox.com/code/data/ticker.php").read)['ticker']
  
  last = "%0.2f" % data['last']
  high = "%0.2f" % data['high']
  low  = "%0.2f" % data['low']
  
  "P\tMt. Gox: $#{last} (high: $#{high}, low: $#{low})"
end

load 'boilerplate.rb'
