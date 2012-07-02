def remspan(ccd, i)
  ccd[i].children.first.remove
  ccd[i].text
end

def parse_conditions(doc)
  location = doc.css('div.point-forecast-area-title').text
  conditions = doc.css('p.myforecast-current').text
  tempf = doc.css('p.myforecast-current-lrg').text
  tempc = doc.css('span.myforecast-current-sm').text
  ccd = doc.css('ul.current-conditions-detail').children
  humidity = remspan(ccd, 0)
  wind = remspan(ccd, 2)
  updated_at = doc.css('p.current-conditions-timestamp').text
  updated_at = updated_at.gsub(/Last Update on /i, '')

  "#{location}: #{conditions} (#{tempf}, #{tempc})  Wind: #{wind}  RH: #{humidity}  #{updated_at}"
end

$args = ENV['ZIP'] if $args.length == 0
doc = noko_get("http://forecast.weather.gov/zipcity.php?inputstring=#", $args)
if (conds = parse_conditions(doc))
  reply conds
else
  reply "Error parsing conditions for #{$args}"
end
