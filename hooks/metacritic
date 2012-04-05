#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'cgi'

def metacritic_search(game)
  node = Nokogiri(read_url("http://www.metacritic.com/search/all/#{CGI.escape(game)}/results")).css('.main_stats').first
  title = node.css('.product_title').text
  score = node.css('.metascore').text
  [title, score]
end

def handle_command(nick, dest, args)
  mc = metacritic_search(args)
  "P\t#{mc}"
end

load 'boilerplate.rb'
