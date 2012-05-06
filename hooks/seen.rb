def last_statement(nick, chan)
  last = DB[:last]
  last = last.filter(:chan => chan) if chan
  last = last.order(:at.desc)
  if nick
    last.all_regex(:nick, nick).first
  else
    last.first
  end
end

MINUTE_SECONDS = 60
HOUR_SECONDS = 3600
DAY_SECONDS = 86400
WEEK_SECONDS = 604800
MONTH_SECONDS = 2246400

def format_message(row)
  timediff = Time.now.to_i - row[:at]
  if timediff > WEEK_SECONDS
    if timediff <= MONTH_SECONDS
      formatstr = '%a %b %d'
    else
      formatstr = '%b %d %Y'
    end
    at = Time.at(row[:at]).strftime(formatstr)
  else
    if timediff <= MINUTE_SECONDS
      at = "#{timediff}s"
    elsif timediff <= HOUR_SECONDS
      minutes = timediff / MINUTE_SECONDS
      seconds = timediff - minutes * MINUTE_SECONDS
      at = "#{minutes}m #{seconds}s"
    elsif timediff <= DAY_SECONDS
      hours = timediff / HOUR_SECONDS
      minutes = (timediff - hours * HOUR_SECONDS) / MINUTE_SECONDS
      at = "#{hours}h #{minutes}m"
    else #timediff > DAY_SECONDS && timediff <= WEEK_SECONDS
      days = timediff / DAY_SECONDS
      hours = (timediff - days * DAY_SECONDS) / HOUR_SECONDS
      at = "#{days}d #{hours}h"
    end
    at << ' ago'
  end

  text = row[:stmt]
  if text =~ /^\001ACTION (.+)\001/
    text = "* #{row[:nick]} #{$1}"
  else
    text = "<#{row[:nick]}> #{text}"
  end
  "[#{at}] #{row[:chan]} #{text}"
end

# ---

m = match_args(/(\S+)\s*(\S+)?/, '<nick> [<channel>]')
nick, chan = m[1], m[2]

if IRC.channel_name?(nick)
  chan = nick
  nick = nil
end

row = last_statement(nick, chan)

msg =
  if row
    format_message(row)
  elsif nick
    "#{nick}#{chan} has not spoken since my log began"
  else
    "no one has spoken in #{chan} since my log began"
  end
reply(msg)
