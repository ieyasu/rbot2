require 'chronic'

m = match_args(/([^;]+);\s*(.+)/, '<date>; <message> -- date can be one of many formats, e.g. "thursday 2:35", "7 days from now" or "jan 5 2018"')
time, text = m[1], m[2]

if (at = Chronic.parse(time))
  DB[:cron].insert(at.to_i, $msg.nick, $msg.dest, text)
  fat = at.strftime('%a %d %b %H:%M:%S %Z')
  priv_reply("queueing '#{text}' to be replayed at #{fat}")
else
  reply("bad time format '#{time}'")
end
