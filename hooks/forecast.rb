#!/usr/bin/env ruby

MAX_FORECAST_LINES = 6

def unhtml(str)
    str.gsub(/<[^>]+>/, ' ').gsub('&deg;', '').squeeze(' ').strip
end

def parse_choose(body)
    return nil unless body.index('Choose Location from the Following List')

    i = body.index('Enter Your') or return nil
    i = body.index(/<a href=['"]?(\/\/[^'">]+)['"]?>/, i) or return nil
    $1
end

def parse_forecast(body)
    i = -1
    loop do
        i += 1
        break if body[i] =~ /<a name=['"]contents['"].*>/ # "
        return nil unless i < body.length
    end

    forecast = []
    body = body[i..-1].join('')
    i = 0
    begin
        if (i = body.index(/(<b>[^<]+<\/b>[^<]+<br>)/, i))
            forecast << unhtml($1)
        else
            break
        end
        i += $1.length
    end while i < body.length && forecast.length < MAX_FORECAST_LINES
    forecast.collect { |line| "P\t#{line}\n" }.join
end

def handle_command(nick, dest, args)
    args = ENV['ZIP'] if args.length == 0
    url = "zipcity.php?inputstring=#{CGI.escape(args)}"
    body = read_url("http://www.crh.noaa.gov/#{url}")

    if (url = parse_choose(body))
        body = read_url("http:#{url}")
    end

    if body
        parse_forecast(body.split(/\n/)) || "P\terror parsing weather for #{args}"
    else
        "P\terror looking up weather for #{args}"
    end
end

load 'boilerplate.rb'
