#!/usr/bin/env ruby

require 'nokogiri'
require 'json'

def handle_command(nick, dest, args)
  doc = Nokogiri::HTML(read_url("https://www.tradehill.com/MarketData/"))
  data = doc.css("div#ticker2").xpath('table/tr/td').text
  match = data.match(/Last: (\d+.\d+) USD, .+Highest Bid: (\d+.\d+)Lowest Ask: (\d+.\d+)/)
  last, bid, ask = [1,2,3].map { |n| sprintf("$%0.2f", Float(match[n])) }

  weighted = Float(JSON.parse(read_url("http://bitcoincharts.com/t/weighted_prices.json"))["USD"]["24h"])

  "P\tTradeHill: #{last} -- bid: #{bid}, ask: #{ask}, 24h weighted: #{sprintf("$%0.2f", weighted)}"
end

load 'boilerplate.rb'
