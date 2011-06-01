#!/usr/bin/env ruby

def parse_choose(body, fin)
  i = body.index('More than one match was found') ||
    ((j = body.index('More than one location matched')) &&
     body.index('<td valign="top">', j))
  if i
    body.index(%r!<a\s+href\s*=\s*['"]?([^'">]+)['"]?!i, i) or return
    fin.base_uri.merge($1)
  end
end

def extract_td(body, i, sigil)
  i = body.index(sigil, i) or return
  i = body.index('<td', i) or return
  j = body.index('</td>', i) or return
  [strip_html(body[i...j].gsub('&deg;', '')), j]
end

def parse_conditions(body)
  i = body.index(/Current local weather/i) or return

  i = body.index(/<span class=.blue1/, i) or return
  j = body.index("</span", i) or return
  location = strip_html(body[i...j])

  i = body.index(/Last Update on [^,]+,([^<]+)<br>/, j) or
    i = body.index(/Last Update on \d\d? \w+ ([^<]+)<br>/) or return
  update_at = $1.strip

  conditions, i = extract_td(body, i, '<table')
  return unless conditions
  conditions =~ /'([^']+)'\s*(\d+)\s*F\s*\((\d+)\s*C\)/
  conditions,tempf,tempc = $1,$2,$3

  humidity, i = extract_td(body, i, 'Humidity')
  return unless humidity
  humidity = humidity.delete(' ')

  wind, i = extract_td(body, i, 'Wind Speed')
  return unless wind
  wind = "from #{wind}" unless wind =~ /calm/i

  "#{location}: #{conditions} (#{tempf}F, #{tempc}C)  Wind: #{wind}  RH: #{humidity}  #{update_at}"
end

def handle_command(nick, dest, args)
  args = ENV['ZIP'] if args.length == 0
  fin = open("http://forecast.weather.gov/zipcity.php?inputstring=#{CGI.escape(args)}")
  body = fin.read

  if body && (url = parse_choose(body, fin))
    p url
    fin = open(url)
    body = fin.read
  end

  while body && body.index(/document.location.replace\('([^']+)'\)/)
    fin = open(fin.base_uri.merge($1))
    body = fin.read
  end

  if body
    if body.index('Could not find your')
      "P\tWeather location #{args} not found"
    elsif body.index('Current Conditions Unavailable')
      "P\tWeather conditions are unavailable"
    elsif (res = parse_conditions(body))
      res.index('NULL') ?
      "P\tNWS is spitting out NULLs again" :
        "P\t#{res}"
    else
      "P\tError parsing weather information for #{args}"
    end
  else
    "P\tNo weather information for #{args}"
  end
end

load 'boilerplate.rb'
