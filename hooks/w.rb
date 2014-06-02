require 'wunderground'
require 'date'

w = Wunderground.new($rbconfig['wunderground_key'])

$args = ENV['ZIP'] if $args.length == 0

wx = w.conditions_for($args)['current_observation']
if wx then
  out = "#{wx['display_location']['full']} #{wx['observation_time'][/, (.+$)/, 1]}: #{wx['weather']} #{wx['temp_f']}F, #{wx['relative_humidity']}, wind #{wx['wind_dir']} at #{wx['wind_mph']} mph"
  out += " gust #{wx['wind_gust_mph']}" if wx['wind_gust_mph'].to_f > 0
  out += ", precip today: #{wx['precip_today_in']}" if wx['precip_today_in'].to_f > 0
  reply(out)
else
  reply("Error occurred or location not found")
end
