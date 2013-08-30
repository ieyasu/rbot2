#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# for parsing saved html from 
# http://en.wikipedia.org/wiki/List_of_North_American_Numbering_Plan_area_codes

require 'nokogiri'

###

if ARGV.length != 1
  puts "Usage: parse_wp_area_codes area_codes.html"
  exit 1
end

File.open(ARGV[0]) do |fin|
  doc = fin.read
  doc.scan(%r!<p>(?:<a[^>]+>)?<b>((?:[^<]|<[^b])+)</b>(?:: )?((?:.|\r?\n[^<>]+)+)</p>!) do |code, desc|
    code = code.gsub(%r!<a[^>]+>!, '').gsub(%r!</a>!, '')
    desc = desc.strip.gsub(%r!\r\n?!, '')
    desc = desc.gsub(%r!<[^>]+>!, '')
    desc = desc.gsub(/\[(?:\d{1,3}|citation needed)\]/i, '')

    if code =~ /(\d\d\d)\D(\d\d\d)/
      ($1.to_i..$2.to_i).each {|i| puts "#{i} - #{desc}" }
    else
      puts "#{code} - #{desc}"
    end
  end
end
