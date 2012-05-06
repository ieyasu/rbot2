#!/usr/bin/env ruby

TZ = {
  ["-4", "0"] => "America/Puerto_Rico",
  ["-5", "0"] => "CST",
  ["-5", "1"] => "America/New_York",     # eastern
  ["-6", "1"] => "America/Chicago",      # central
  ["-7", "0"] => "America/Phoenix",      # MST
  ["-7", "1"] => "America/Denver",       # mountain
  ["-8", "1"] => "America/Los_Angeles",  # pacific
  ["-9", "1"] => "America/Anchorage",
  ["-10", "0"] => "Pacific/Honolulu",
  ["-10", "1"] => "America/Adak"
}

while (line = gets)
  if line.length > 2
    next unless line =~ /^"\d/
    ary = line.gsub('"', '').strip.split(/,/)
    if ary.length != 7
      raise "Bad line #{line.inspect}"
    end
    td = ary[5..6]
    ary[5..6] = TZ[td]
    puts ary.join(',')
  end
end
