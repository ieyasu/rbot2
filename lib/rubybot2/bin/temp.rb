#!/usr/bin/env ruby

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

  "CSU: #{munge_time(time)}: #{temp}F #{rh}% #{munge_direction(wd)} at #{ws}mph g #{gust}"
end

def handle_command(nick, dest, args)
  body = open("http://www.atmos.colostate.edu/wx/fcc/fccwx_current.php").read
  if (conds = parse_csu_conds(body))
    "P\t#{conds}"
  else
    "P\terror parsing CSU weather conditions"
  end
end

load 'boilerplate.rb'
