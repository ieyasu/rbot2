#!/usr/bin/env ruby

def parse_b(body, name)
  i = body.index(name) or return
  i = body.index('<b>', i) or return
  j = body.index('</b>', i) or return
  return strip_html(body[i...j])
end

def parse_td(body, name)
  i = body.index(Regexp.new("td>#{name}</td", Regexp::IGNORECASE)) or return
  i = body.index(/<td/i, i) or return
  j = body.index(/<\/td/i, i) or return
  strip_html(body[i...j])
end

def parse_conditions(body)
  time = parse_b(body, 'Updated:') or return
  loc = parse_b(body, 'Observed at') or return
  temp = parse_td(body, 'Temperature') or return
  hum = parse_td(body, 'Humidity')
  wind = parse_td(body, 'Wind')
  cond = parse_td(body, 'Conditions')
  "#{loc} #{time}: #{cond} #{temp} #{hum} #{wind}".
    gsub(%r!/ +(\S+\s+\S+)!, '(\\1)').
    gsub(/(\d) +([CF])/, '\\1\\2').
    gsub(/miles/i, 'mi').
    gsub(/kilometers/i, 'km').
    squeeze(' ').strip
end

def handle_command(nick, dest, args)
  args = ENV['ZIP'] if args.length == 0
  body = read_url("http://mobile.wunderground.com/cgi-bin/findweather/getForecast?brand=mobile&query=#{CGI.escape(args)}")
  if body && (res = parse_conditions(body))
    "P\t#{res}"
  else
    "P\terror parsing weather information for #{args}"
  end
rescue OpenURI::HTTPError => e
  "P\terror looking up weather for #{args}: #{e.message}"
end

load 'boilerplate.rb'
