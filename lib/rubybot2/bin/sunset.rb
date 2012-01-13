#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'pp'

def present(n)
  s = n.first.content.strip.sub('Sunrise', '').sub(':', ":\002").
    sub('Sunset:', ' -')
  "\002#{Time.now.strftime('%b')} #{s}"
end

def parse(doc)
  t = Time.now
  month = t.strftime('%b')
  sun = "Sunrise-set: "

  n = doc.xpath(".//table[1]/tr/td[./font[1]/text()='#{t.day}']")
  s = present(n).sub(':', " (Today):").
    gsub(/(\d\d?:\d\d[ap]m)/, "\00308\\1\003")
  sun << "#{s}   "

  n = doc.xpath('.//table[1]/tr[2]/td[1]')
  sun << "#{present(n)}   "

  n = doc.xpath('.//table[1]/tr[last()]/td[1]')
  sun << present(n)

  sun
end

def handle_command(nick, dest, args)
  t = Time.now
  doc = Nokogiri::HTML(open("http://www.sunrisesunset.com/calendar.asp?comb_city_info=Denver%2C%20Colorado;104.9847;39.7392;-7;1&month=#{t.month}&year=#{t.year}&time_type=0&txsz=S&back=&supr=6334&want_mphase=0"))
  if (sun = parse(doc))
    "P\t#{sun}"
  else
    "P\terror parsing sunrise/sunset info"
  end
end

load 'boilerplate.rb'
