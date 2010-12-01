#!/usr/bin/env ruby

def triple_strip(body, i, *pats)
    lastpat = pats.pop
    pats.each do |pat|
        j = body.index(pat, i) or return [nil, i]
        i = j
    end
    j = body.index(lastpat, i) or return [nil, i]
    [strip_html(body[i...j]), j]
end

def parse_gust(body, i)
    gust, i = triple_strip(body, i, 'Wind Gust:', '<b>', '</b>')
    (gust && gust.to_f > 0.0) ? " G #{gust}" : ''
end

def parse_normal_conditions(body)
    i = body.index(%r!<h1>([^>]+)</h1>!) or return
    location = strip_html($1)

    time, i = triple_strip(body, i, 'Updated:', '<span', />\d/, 'o')
    return unless time

    temp, j = triple_strip(body, i, /<span[^>]+pwsvariable="tempf"/, '<b>', '</b>')
    tmp, d = triple_strip(body, j, '<b>', '</b>')
    return unless temp && tmp
    temp = "#{temp}F (#{tmp}C)"

    conds, d = triple_strip(body, i, '<div id="b"', '</div>')

    hum, d = triple_strip(body, i, 'Humidity:', '<b>', '</b>')

    wind, j = triple_strip(body, i, 'Wind:', '<span', '</span>')
    if wind && (k = wind.index('mph'))
        wind = wind[0..k + 3].gsub(/\s+/, '')
    end
    wdir, d = triple_strip(body, j, 'from the', '<span', '</span>')

    gust = parse_gust(body, i)

    pressure, d = triple_strip(body, i, 'Pressure:', '<b>', '</b>')

    vis, j = triple_strip(body, i, 'Visibility:', '<b>', '</b>')

    "#{location} #{time[1..-1]}: #{conds} #{temp} #{hum} #{wind}#{gust} #{wdir} Vis #{vis}mi Prs #{pressure}in".squeeze(' ')
end

def strip_html_ws(html)
    strip_html(html).gsub(/(\d)\s+(\w)/, '\\1\\2')
end

def parse_search_conditions(body)
    return if body.index(/City Not Found/i)

    i = body.index('Place</span>') or return

    loc, i = triple_strip(body, i, '<td class="sortC"', '<a', '</a>')
    return unless loc

    temp, i = triple_strip(body, i, '<td class="sortC"', '<b', '</td>')
    return unless temp
    temp = temp.gsub(/\s+/, '')

    i = body.index('<td class="sortC"', i) or return
    j = body.index('</td>', i) or return
    hum = strip_html_ws(body[i...j])

    press, i = triple_strip(body, j, '<td class="sortC"', '<b', '</td>')
    press = press ? strip_html_ws(press) : ''

    i = body.index('<td class="sortC"', i) or return
    j = body.index('</td>', i) or return
    conds = strip_html_ws(body[i...j])

    i = body.index('<td class="sortC"', j) or return
    j = body.index('</td>', i) or return
    wind = strip_html_ws(body[i...j])

    i = body.index('<td class="sortC"', j) or return
    j = body.index('</td>', i) or return
    update = strip_html(body[i...j])

    "#{loc} #{update}: #{conds} #{temp} #{hum} #{wind} Prs #{press}"
end

def parse_conditions(body)
    parse_search_conditions(body) || parse_normal_conditions(body)
end

def handle_command(nick, dest, args)
    args = zip_by_nick(nick) if args.length == 0
    body = open("http://www.wunderground.com/cgi-bin/findweather/getForecast?query=#{CGI.escape(args)}").read
    if body && (res = parse_conditions(body))
        "P\t#{res}"
    else
        "P\terror parsing weather information for #{args}"
    end
rescue OpenURI::HTTPError => e
    "P\terror looking up weather for #{args}: #{e.message}"
end

load 'boilerplate.rb'
