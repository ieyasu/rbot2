STATES = {
  "ALABAMA"                        => "AL",
  "ALASKA"                         => "AK",
  "AMERICAN SAMOA"                 => "AS",
  "ARIZONA"                        => "AZ",
  "ARKANSAS"                       => "AR",
  "CALIFORNIA"                     => "CA",
  "COLORADO"                       => "CO",
  "CONNECTICUT"                    => "CT",
  "DELAWARE"                       => "DE",
  "DISTRICT OF COLUMBIA"           => "DC",
  "FEDERATED STATES OF MICRONESIA" => "FM",
  "FLORIDA"                        => "FL",
  "GEORGIA"                        => "GA",
  "GUAM"                           => "GU",
  "HAWAII"                         => "HI",
  "IDAHO"                          => "ID",
  "ILLINOIS"                       => "IL",
  "INDIANA"                        => "IN",
  "IOWA"                           => "IA",
  "KANSAS"                         => "KS",
  "KENTUCKY"                       => "KY",
  "LOUISIANA"                      => "LA",
  "MAINE"                          => "ME",
  "MARSHALL ISLANDS"               => "MH",
  "MARYLAND"                       => "MD",
  "MASSACHUSETTS"                  => "MA",
  "MICHIGAN"                       => "MI",
  "MINNESOTA"                      => "MN",
  "MISSISSIPPI"                    => "MS",
  "MISSOURI"                       => "MO",
  "MONTANA"                        => "MT",
  "NEBRASKA"                       => "NE",
  "NEVADA"                         => "NV",
  "NEW HAMPSHIRE"                  => "NH",
  "NEW JERSEY"                     => "NJ",
  "NEW MEXICO"                     => "NM",
  "NEW YORK"                       => "NY",
  "NORTH CAROLINA"                 => "NC",
  "NORTH DAKOTA"                   => "ND",
  "NORTHERN MARIANA ISLANDS"       => "MP",
  "OHIO"                           => "OH",
  "OKLAHOMA"                       => "OK",
  "OREGON"                         => "OR",
  "PALAU"                          => "PW",
  "PENNSYLVANIA"                   => "PA",
  "PUERTO RICO"                    => "PR",
  "RHODE ISLAND"                   => "RI",
  "SOUTH CAROLINA"                 => "SC",
  "SOUTH DAKOTA"                   => "SD",
  "TENNESSEE"                      => "TN",
  "TEXAS"                          => "TX",
  "UTAH"                           => "UT",
  "VERMONT"                        => "VT",
  "VIRGIN ISLANDS"                 => "VI",
  "VIRGINIA"                       => "VA",
  "WASHINGTON"                     => "WA",
  "WEST VIRGINIA"                  => "WV",
  "WISCONSIN"                      => "WI",
  "WYOMING"                        => "WY",
}

def state_sub(s)
  if s =~ /, ([\w\s]+)$/
    state = $1
    if (st = STATES[state.upcase])
      s = s.sub(state, st)
    end
  end
  s
end

def parse_b(body, name)
  i = body.index(name) or return
  i = body.index('<b>', i) or return
  j = body.index('</b>', i) or return
  return strip_html(body[i...j])
end

def parse_td(body, name)
  i = body.index(Regexp.new("td>#{name}</td", Regexp::IGNORECASE)) or return
  i = body.index(/<td/i, i) or return
  j = body.index(/<\/td/i, i) or return
  strip_html(body[i...j])
end

def parse_conditions(body)
  time = parse_b(body, 'Updated:') or return
  time = time.sub(/ on.*/, '').sub(/(\d)\s*([AP]M)/i, "\\1\\2").
    sub(/ [PMCE][SD]T/, '')
  loc = parse_b(body, 'Observed at') or return
  loc = state_sub(loc)
  loc = loc.sub(/[^,]+, /, '') if loc =~ /,[^,]+,/
  temp = parse_td(body, 'Temperature') or return
  hum = parse_td(body, 'Humidity')
  wind = parse_td(body, 'Wind')
  wind = wind.sub(/\s*\/.*/, '')
  cond = parse_td(body, 'Conditions')
  "#{loc} #{time}: #{cond} #{temp} #{hum} #{wind}".
    gsub(%r!/ +(\S+\s+\S+)!, '(\\1)').
    gsub(/(\d) +([CF])/, '\\1\\2').
    gsub(/miles/i, 'mi').
    gsub(/kilometers/i, 'km').
    squeeze(' ').strip
end

$args = ENV['ZIP'] if $args.length == 0
body = http_get("http://mobile.wunderground.com/cgi-bin/findweather/getForecast?brand=mobile&query=#", $args)
if body && (res = parse_conditions(body))
  reply res
else
  reply "error parsing weather information for #{$args}"
end
