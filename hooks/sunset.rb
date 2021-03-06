LOCAL_ZIP = /^80[235]\d\d$/ # denver, boulder, fort collins


def rise_set_for(doc, day)
  n = doc.xpath(".//table[1]/tr/td[./font[1]/text()='#{day}']")
  s = n.first.content.strip.sub('Sunrise', '').
    sub('Sunset:', ' -')
  "#{Time.now.strftime('%b')} #{s}"
end

def denver_sunset
  t = Time.now
  doc = noko_get("http://www.sunrisesunset.com/calendar.asp?comb_city_info=Denver%2C%20Colorado;104.9847;39.7392;-7;1&month=#&year=#&time_type=0&txsz=S&back=&supr=6334&want_mphase=0", t.month, t.year)

  t = Time.now
  month = t.strftime('%b')
  sun = "Denver Sunrise-set: "

  # sunrise/set for today
  s = rise_set_for(doc, t.day).sub(':', " (Today):").
    gsub(/(\d\d?:\d\d[ap]m)/, "\00304\\1\003")
  reply "Denver Sunrise-set: #{s}"

  # sunrise/set for first of month
  sun = "#{rise_set_for(doc, 1)}   "

  # sunrise/set for end of month
  eom = Date.civil(t.year, t.month, -1)
  sun << rise_set_for(doc, eom.day)

  reply sun
end

def wunder_sunset(location)
  body = http_get("http://m.wund.com/cgi-bin/findweather/getForecast?brand=mobile&query=#", location)

  if body.index('Not Found')
    return "#{location} not found"
  end

  i = body.index('Observed at') or return
  i = body.index('<b>', i) or return
  j = body.index('</b>', i) or return
  loc = strip_html body[i...j]

  i = body.index('<td>Sunrise', i) or return
  i = body.index('<td', i + 10) or return
  j = body.index('</td', i) or return
  rise = strip_html body[i...j]

  i = body.index('<td>Sunset') or return
  i = body.index('<td', i + 10) or return
  j = body.index('</td', i) or return
  set = strip_html body[i...j]

  "#{loc} - Sunrise: \00304#{rise}\003  Sunset: \00304#{set}\003"
end

location = $args.length > 0 ? $args : ENV['ZIP']
if location =~ LOCAL_ZIP
  denver_sunset
else
  if (sun = wunder_sunset(location))
    reply sun
  else
    reply "error parsing sunrise/sunset info for #{location}"
  end
end
