#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'

LOCAL_ZIP = /^80[235]\d\d$/ # denver, boulder, fort collins

def present(n)
  s = n.first.content.strip.sub('Sunrise', '').sub(':', ":\002").
    sub('Sunset:', ' -')
  "\002#{Time.now.strftime('%b')} #{s}"
end

def denver_sunset
  t = Time.now
  doc = Nokogiri::HTML(open("http://www.sunrisesunset.com/calendar.asp?comb_city_info=Denver%2C%20Colorado;104.9847;39.7392;-7;1&month=#{t.month}&year=#{t.year}&time_type=0&txsz=S&back=&supr=6334&want_mphase=0"))

  t = Time.now
  month = t.strftime('%b')
  sun = "Denver Sunrise-set: "

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

def wunder_sunset(location)
  body = open("http://m.wund.com/cgi-bin/findweather/getForecast?brand=mobile&query=#{CGI.escape location}").read

  i = body.index('Observed at') or return
  i = body.index('<b>', i) or return
  j = body.index('</b>', i) or return
  loc = strip_html body[i...j]

  i = body.index('<td>Sunrise', i) or return
  i = body.index('<td', i + 10) or return
  j = body.index('</td', i) or return
  rise = strip_html body[i...j]

  i = body.index('<td>Sunset') or return
  i = body.index('<td', i + 10) or return
  j = body.index('</td', i) or return
  set = strip_html body[i...j]

  "#{loc} - Sunrise: \00308#{rise}\003  Sunset: \00308#{set}\003"
end

def handle_command(nick, dest, args)
  location = (args && args.length) > 0 ? args : ENV['ZIP']
  sun =
    if location =~ LOCAL_ZIP
      denver_sunset
    else
      wunder_sunset(location)
    end

  if sun
    "P\t#{sun}"
  else
    "P\terror parsing sunrise/sunset info for #{location}"
  end
end

load 'boilerplate.rb'
