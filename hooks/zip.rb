#!/usr/bin/env ruby

SYNTAX = 'Usage: !zip (<zip code>|<city>, <st>)'
URL = 'http://www.census.gov/cgi-bin/gazetteer?'

def parse(body)
  i = body.index('<li>') or return
  j = body.index('<br>', i) or return

  k = body.index('Zip Code:', i)
  if k && k < j
    body[i + 4...j] =~
      /<strong>Zip Code: (\d{5})<\/strong>  PO Name: ([^)]+)\((\w\w)\)/ or return
    ["#{$2.strip}, #{$3}", $1]
  else
    cityst = strip_html(body[i...j].gsub(/\([^)]+\)/, ''))

    i = body.index('Zip Code(s):', j) or return
    j = body.index('<br>', i) or return
    zips = strip_html(body[i + 12...j])

    [cityst, zips]
  end
end

def handle_command(nick, dest, args)
  city = state = zip = nil
  case args
  when /\d{5}/
    zip = args
  when /([^,]+)\s*,\s*(.{2,})/
    return "P\t#{$1} is too long" if $1.length > 35
    city = CGI.escape($1)
    state = CGI.escape($2)
  when /\w+/
    city = CGI.escape(args)
  else
    return "P\t#{SYNTAX}"
  end
  body = read_url("http://www.census.gov/cgi-bin/gazetteer?city=#{city}&state=#{state}&zip=#{zip}")
  cityst, zips = parse(body)
  return "P\t#{args} was not found" unless zips

  if zip
    "P\tzip code #{zip} is in #{cityst}"
  else
    zips = zips.split
    s = zips.length > 1 ? 's' : ''
    "P\t#{cityst} has zip code#{s} #{zips.join(', ')}"
  end
end

load 'boilerplate.rb'
