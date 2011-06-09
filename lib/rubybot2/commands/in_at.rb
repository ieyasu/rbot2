require 'chronic'
require 'rubybot2/db'

class InAt
    IN_SYNTAX = 'usage: !in <delay>[;] <message>'
    AT_SYNTAX = 'usage: !at <time>[;] <message>'

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
        dt = Time.now.to_i
        if delay =~ /(?:^|\s)(\d+)\s*(?:y(?:ears?)?(?:[\w\s\d]|$))/i
          dt += $1.to_i * 365 * 24 * 3600
        end
        if delay =~ /(?:^|\s)(\d+)\s*(?:d(?:ays?)?(?:[\w\s\d]|$))/i
            dt += $1.to_i * 24 * 3600
        end
        if delay =~ /(?:^|\s)(\d+)\s*(?:h(?:(?:ou)?rs?)?)(?:[\w\s\d]|$)/i
            dt += $1.to_i * 3600
        end
        if delay=~ /(?:^|\s)(\d+)\s*(?:m(?:(?:in(?:ute)?)?s?)?)(?:[\w\s\d]|$)/i
            dt += $1.to_i * 60
        end
        if delay =~ /(?:^|\s)(\d+)\s*(?:s(?:ec(?:onds?)?)?)(?:[\w\s\d]|$)/i
            dt += $1.to_i
        end
        dt
    end

    def insert_job(at, msg, text, r)
        DB[:cron].insert(at, msg.nick, msg.dest, text)
        fat = Time.at(at).strftime('%a %d %b %H:%M')
        r.priv_reply("queueing '#{msg}' to be replayed at #{fat}")
    end
end
