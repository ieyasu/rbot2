#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'json'

def handle_command(nick, dest, args)
  data = JSON.parse(open("https://mtgox.com/code/data/ticker.php").read)['ticker']
  data['24h'] = Float(JSON.parse(open("http://bitcoincharts.com/t/weighted_prices.json").read)["USD"]["24h"])

  last = "$%0.2f" % data['last']
  prices = %w(buy sell 24h).map do |price|
    "#{price}: $%0.2f" % data[price]
  end.join(", ")

  "P\tMt. Gox: #{last} -- #{prices}, vol: #{data['vol']} BTC"
end

load 'boilerplate.rb'
