require 'wunderground'
require 'date'

w = Wunderground.new($rbconfig['wunderground_key'])

# if not location specified, check PWS ID first, then zip
if $args.length == 0
  $args = "pws:" + ENV['PWS'] unless ENV['PWS'].nil?
  $args = ENV['ZIP'] if ENV['PWS'].nil?
end

wx = w.conditions_for($args)['current_observation']
if wx then
  out = "#{wx['observation_location']['city']}, #{wx['display_location']['state']} #{wx['observation_time'][/, (.+$)/, 1]}: #{wx['weather']} #{wx['temp_f']}F, #{wx['relative_humidity']}, wind #{wx['wind_dir']} at #{wx['wind_mph']} mph"
  out += " gust #{wx['wind_gust_mph']}" if wx['wind_gust_mph'].to_f > 0
  out += ", precip today: #{wx['precip_today_in']}" if wx['precip_today_in'].to_f > 0
  reply(out)
else
  reply("Error occurred or location not found")
end
