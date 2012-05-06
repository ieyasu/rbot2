require 'date'

def parse_delay(delay)
  dt = DateTime.now
  now = DateTime.now
  if delay =~ /(?:^|\s)(\d+)\s*(?:y(?:ears?)?(?:[;\s\d]|$))/i
    dt = dt.next_year($1.to_i)
  end
  if delay =~ /(?:^|\s)(\d+)\s*(?:mon(?:ths?)?(?:[;\s\d]|$))/i
    dt = dt.next_month($1.to_i)
  end
  if delay =~ /(?:^|\s)(\d+)\s*(?:d(?:ays?)?(?:[;\s\d]|$))/i
    dt = dt.next_day($1.to_i)
  end
  if delay =~ /(?:^|\s)(\d+)\s*(?:h(?:(?:ou)?rs?)?)(?:[;\s\d]|$)/i
    dt += $1.to_f / 24.0
  end
  if delay =~ /(?:^|\s)(\d+)\s*(?:m(?:(?:in(?:ute)?)?s?)?)(?:[;\s\d]|$)/i
    dt += $1.to_f / 1440.0
  end
  if delay =~ /(?:^|\s)(\d+)\s*(?:s(?:ec(?:onds?)?)?)(?:[;\s\d]|$)/i
    dt += $1.to_f / 86400.0
  end
  (dt > now) ? dt.to_time.to_i : nil
end

# ---

m = match_args(/([^;]+);\s*(.+)/, '<delay>; <message> -- delay is some combo of y(ears), mon(th), d(ay), hour, min, sec')
delay, text = m[1], m[2]

if (at = parse_delay(delay))
  DB[:cron].insert(at, $msg.nick, $msg.dest, text)
  fat = Time.at(at).strftime('%a %d %b %H:%M:%S %Z')
  priv_reply("queueing '#{text}' to be replayed at #{fat}")
else
  reply("bad delay format '#{delay}'.  Use something like '1y 5days 4 min 6s'")
end
