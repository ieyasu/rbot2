#!/usr/bin/env ruby

DIRECTIONS = {
  'north' => 'N',
  'south' => 'S',
  'east'  => 'E',
  'west'  => 'W',
  'northwest' => 'NW',
  'northeast' => 'NE',
  'southwest' => 'SW',
  'southeast' => 'SE',
  'north northeast' => 'NNE',
  'north northwest' => 'NNW',
  'west northwest'  => 'WNW',
  'west southwest'  => 'WSW',
  'south southwest' => 'SSW',
  'south southeast' => 'SSE',
  'east southeast'  => 'ESE',
  'east northeast'  => 'ENE'
}

def parse_choose(body)
  return unless (i = body.index(/<h1[^>]*>Search Results for/i))
  body.index(%r!<li><a href="(/weather/local/[^"]+)"!) or return #"
  "http://www.weather.com#{$1}"
end

def parse_conditions(body)
  i = body.index('<h1>') or return
  j = body.index('</h1>', i) or return
  location = strip_html(body[i...j]).gsub(/\s*Weather/, '')

  i = body.index('Updated:', i) or return
  i = body.index(%r!(\d?\d:\d\d(?:[ap]m)?)!i, i) or return
  time = $1

  i = body.index('class="twc-forecast-temperature') or return
  i = body.index(%r!strong>(-?\d+)&deg;\s*F!, i) or return
  temp = "#{$1}F"

  i = body.index('Feels Like:', i) or return
  i = body.index(%r!(-?\d+)&deg;!, i) or return
  feelslike = "#{$1}F"

  i = body.index('Wind:', i) or return
  if body.index(%r!<dd[^>]*>([^<]+)</dd!, i)
    wind = strip_html($1)
  elsif body.index(/From\s*(\S+)\s*at\s*(\S+)/, i)
    wind = "#{$1} #{strip_html($2)}"
  else
    return
  end

  "#{location} #{time}: #{temp} (Feels like #{feelslike}) [Wind: #{wind}]"
end

def munge_time(time)
  time =~ /(\d\d)(:\d\d)/
  h = $1.to_i
  if h > 12
    "#{h - 12}#{$2} PM"
  else
    "#{$1}#{$2} AM"
  end
end

def munge_direction(wd)
  deg = wd.to_i
  case ((deg + 22 % 360) / 45) % 8
  when 0 then 'N'
  when 1 then 'NE'
  when 2 then 'E'
  when 3 then 'SE'
  when 4 then 'S'
  when 5 then 'SW'
  when 6 then 'W'
  when 7 then 'NW'
  end
end

def parse_csu_conds(body)
  i = body.index('color:darkred') or return
  i = body.index(/(\d\d-\d\d-\d{4}[^<]+)/, i) or return
  date, time, temp, rh, dewpt, ws, wd, gust, dir, press = $1.split

  "CSU: #{munge_time(time)}: #{temp} F " +
    "[Wind: From #{munge_direction(wd)} (#{wd}) at #{ws} mph gusting #{gust}] " +
    "[RH: #{rh}%, Dewpoint: #{dewpt} F, Pres: #{press}]"
end

def csu_weather
  body = open("http://www.atmos.colostate.edu/wx/fcc/fccwx_current.php").read
  if (conds = parse_csu_conds(body))
    "P\t#{conds}"
  else
    "P\terror parsing CSU weather conditions"
  end
end

def handle_command(nick, dest, args)
  return csu_weather if args.length == 0

  body = open('http://www.weather.com/search/enhancedlocalsearch?' +
              'whatprefs=&what=WeatherLocalUndeclared&lswe&lswa&' +
              'loctypes=1003,1001,1000,1,9,5,11,13,19,20&' +
              'from=searchbox_localwx&' +
              "where=#{CGI.escape(args)}"
              ).read

  if (url = parse_choose(body))
    body = open(url).read
  end

  if body.index('No results found. Try your search again.')
    "P\tweather for #{args} not found"
  elsif (conds = parse_conditions(body))
    "P\t#{conds}"
  else
    "P\terror parsing weather for #{args}"
  end
end

load 'boilerplate.rb'
