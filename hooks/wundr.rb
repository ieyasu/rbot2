#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'

def parse_normal_conditions(doc)
  location = doc.css('#stationName div.b').text
  time = doc.css('#infoTime').text.gsub(/\s*\([^)]*\)/, '')
  conds = doc.css('#curCond').text
  temp = doc.css('#tempActual span.b').text + "F"
  wind = doc.css('#windCompassSpeed').text + "mph"

  "#{location} #{time}: #{conds} #{temp} #{wind}".squeeze(' ')
end

def parse_search_conditions(doc, args)
  if doc.text.index('City Not Found')
    "the location '#{args}' was not found"
  end
end

def parse_conditions(doc, args)
  parse_search_conditions(doc, args) || parse_normal_conditions(doc)
end

def handle_command(nick, dest, args)
  args = ENV['ZIP'] if args.length == 0
  doc = Nokogiri::HTML(open("http://www.wunderground.com/cgi-bin/findweather/getForecast?query=#{CGI.escape(args)}"))
  if doc && (res = parse_conditions(doc, args))
    "P\t#{res}"
  else
    "P\terror parsing weather information for #{args}"
  end
rescue OpenURI::HTTPError => e
  "P\terror looking up weather for #{args}: #{e.message}"
end

load 'boilerplate.rb'
