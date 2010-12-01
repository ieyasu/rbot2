#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'open-uri'

def handle_command(nick, dest, args)
	doc = Hpricot(open('http://www.radioparadise.com/content.php?name=Playlist'))
  now_playing = (doc/'td.lt_blue/a')
  if now_playing
    now_playing = now_playing.first.inner_html.strip
    "P\tNow playing on Radio Paradise: #{now_playing}"
  else
    "P\tCould not find current track on Radio Paradise."
  end
rescue Exception => e
  "P\terror: #{e}"
end

require 'boilerplate' 
