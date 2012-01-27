#!/usr/bin/env ruby

AGES = [18, 0, 11, 22, 3, 14, 25, 6, 17, 28, 9, 20, 1, 12, 23, 4, 15, 26, 7]
OFFSETS = [-1, 1, 0, 1, 2, 3, 4, 5, 7, 7, 9, 9]
DESCRIPTION = ["new", "waxing crescent", "first quarter", "waxing gibbous", "full",
                "waning gibbous", "last quarter", "waning crescent"]

def handle_command(nick, dest, args)
  t = Time.now
  day = (t.day == 31) ? 1 : t.day
  days_into_phase = (AGES[(t.year + 1) % 19] + ((day + OFFSETS[t.month - 1]) % 30) +
                      (t.year < 1900 ? 1 : 0)) % 30
  desci = [((days_into_phase + 2) * 16 / 59.0).to_int, 7].min

  percent_full = (2 * days_into_phase * 100 / 29.0).round
  percent_full = (percent_full - 200).abs if percent_full > 100

  "P\t#{DESCRIPTION[desci]} - #{percent_full}% full"
end

load 'boilerplate.rb'
