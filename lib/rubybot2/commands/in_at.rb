require 'chronic'
require 'rubybot2/db'

class InAt
  IN_SYNTAX = 'usage: !in <delay>; <message> -- delay is some combo of y(ears), mon(th), d(ay), hour, min, sec'
  AT_SYNTAX = 'usage: !at <date>; <message> -- date can be one of many formats, e.g. "thursday 2:35", "7 days from now" or "jan 5 2018"'

  def initialize(client)
  end

  def c_in(msg, args, r)
    delay, text = args.split(';', 2)
    raise '' unless delay && text
    at = parse_delay(delay)
    insert_job(at, msg, text, r)
  rescue RuntimeError
    r.reply(IN_SYNTAX)
  end

  def c_at(msg, args, r)
    time, text = args.split(';', 2)
    raise '' unless time && text
    if (at = Chronic.parse(time))
      insert_job(at, msg, text, r)
    else
      r.priv_reply("bad time format #{args}")
    end
  rescue RuntimeError
    r.reply(AT_SYNTAX)
  end

  private

  def parse_delay(delay)
    dt = DateTime.now
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
    dt.to_time.to_i
  end

  def insert_job(at, msg, text, r)
    DB[:cron].insert(at, msg.nick, msg.dest, text)
    fat = Time.at(at).strftime('%a %d %b %H:%M:%S %Z')
    r.priv_reply("queueing '#{text}' to be replayed at #{fat}")
  end
end
