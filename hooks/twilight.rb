require 'rubybot2/zipdb'
include Zip

if rand < 0.1
  reply("I wish Edward Cullen wasn't married. While I'm wishing 4 things, I wish Edward Cullen wasn't a fictional character ;-) #BreakingDawn #Dreamy")
else
  $args = ENV['ZIP'] if $args.length == 0
  zipinfo = get_zipinfo($args)

  doc = noko_get("http://www.wunderground.com/sky/ShowSky.asp?TheLat=#&TheLon=#&TimeZoneName=#", zipinfo.lat, zipinfo.lon, zipinfo.tz)
  astro = doc.css('div#astro_contain').css('tr')
  (2..4).each do |row|
    tds = astro[row].css('td')
    s, rise, set = [0,1,3].map {|i| tds[i].text }
    reply("#{s}: #{rise} - #{set}")
  end
end
