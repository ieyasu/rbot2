#!/usr/bin/env ruby

require 'rubygems'
require 'rubybot2/web'

include Web

MAX_CONF_LEN = 450

OUTFILE = 'grouphug-new.txt'
fout = File.open(OUTFILE, 'w')

puts "Writing content to #{OUTFILE}"

BASE = "http://archive.grouphug.us"
url = BASE + '/frontpage?page=1624'

IDs = {}

loop do
  doc = noko_get(url)
  paths = doc.css('h2 a')
  confs = doc.css('div.node div.content')
  paths.zip(confs).each do |path, conf|
    title = path[:title]
    if IDs[title]
      puts "Already got #{title}!"
    else
      IDs[title] = true

      s = "[#{title}] #{conf.text.strip.gsub(/\r?\n/, "  ")}"
      if s.length > MAX_CONF_LEN
        i = s.index(/\b/, MAX_CONF_LEN/2)
        s = "#{s[0..i + 1]}... #{BASE}#{path[:href]}"
      end
      fout.puts s
    end
  end

  nxt = doc.xpath("//a[@title='Go to next page']").first[:href]
  url = BASE + nxt

  sleep(7 + rand(15))
  puts "going to #{url} now..."
end

fout.close
