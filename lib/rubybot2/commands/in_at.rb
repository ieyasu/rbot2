require 'chronic'
require 'rubybot2/db'

class InAt
  IN_SYNTAX = 'usage: !in [<y>y(ear)][<m>mon(ths)][<d>d(ays)][<m>min][<s>sec][;] <message>'
  AT_SYNTAX = 'usage: !at <date>[;] <message>'

  def initialize(client)
  end

  def c_in(msg, args, r)
    delay, text = args_split(args)
    at = parse_delay(delay)
    insert_job(at, msg, text, r)
  rescue RuntimeError
    r.reply(IN_SYNTAX)
  end

  def c_at(msg, args, r)
    time, text = args_split(args)
    if (at = Chronic.parse(time))
      insert_job(at, msg, text, r)
    else
      r.priv_reply("bad time format #{args}")
    end
  rescue RuntimeError
    r.reply(AT_SYNTAX)
  end

  private

  def args_split(args)
    ary =
      if (i = args.index(';'))
        [args[0...i].strip, args[i + 1..-1].strip]
      else
        args.split(nil, 2)
      end
    raise '' unless ary.length == 2 && ary[0].length>0 && ary[1].length > 0
    ary
  end

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
