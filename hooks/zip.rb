require 'rubybot2/zipdb'
include Zip

zip = ($args.length > 0) ? $args : ENV['ZIP']
zipinfo = get_zipinfo(zip)

reply("Zipcode #{zip} is in #{zipinfo.city}, #{zipinfo.state}; lat,lon = #{zipinfo.lat}, #{zipinfo.lon}; timezone #{zipinfo.tz}")
reply("Local time is #{Time.now.ctime}")
