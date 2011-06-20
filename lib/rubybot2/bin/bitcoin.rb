#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'json'

def handle_command(nick, dest, args)
   doc = Nokogiri::HTML(open("https://www.tradehill.com/MarketData/") { |response| response.read })
   data = doc.xpath("/html/body/div[4]/fieldset/div/table/tr/td").text
   match = data.match(/Last: (\d+.\d+) USD, .+Highest Bid: (\d+.\d+)Lowest Ask: (\d+.\d+)/)
   last, bid, ask = [1,2,3].map { |n| sprintf("$%0.2f", Float(match[n])) }

  "P\tTradeHill: #{last} -- bid: #{bid}, ask: #{ask}"
end

load 'boilerplate.rb'
