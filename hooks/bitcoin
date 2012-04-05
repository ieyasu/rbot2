#!/usr/bin/env ruby

require 'nokogiri'
require 'json'

def handle_command(nick, dest, args)
  doc = Nokogiri::HTML(read_url("https://mtgox.com"))
  s = %w(lastPrice highPrice lowPrice volume weightedAverage).map do|id|
    doc.css("li##{id}").text.gsub(':', ': ').gsub(/0+$/, '')
  end.join(', ')
  "P\tMt. Gox: #{s}"
end

load 'boilerplate.rb'
