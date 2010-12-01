require 'rubybot2/last'

class Seen
    SYNTAX = 'Usage: !seen <nick>'

    def initialize(client)
    end

    def c_seen(msg, args, r)
        if args.length == 0
            r.reply(SYNTAX)
            return
        end
        nick, chan = args.split(nil, 3)[0,2]
        if IRC.channel_name?(nick)
            chan = nick
            nick = nil
        end

        row = Last.statement(nick, chan)

        msg =
            if row
                format_message(*row)
            elsif nick
                "#{nick}#{chan} has not spoken since my log began"
            else
                "no one has spoken in #{chan} since my log began"
            end
        r.reply(msg)
    end

    alias :c_last :c_seen

    private

    MINUTE_SECONDS = 60
    HOUR_SECONDS = 3600
    DAY_SECONDS = 86400
    WEEK_SECONDS = 604800
    MONTH_SECONDS = 2246400

    def format_message(nick, chan, text, time)
        timediff = Time.now.to_i - time.to_i
        if timediff > WEEK_SECONDS
            if timediff <= MONTH_SECONDS
                formatstr = '%a %b %d'
            else
                formatstr = '%b %d %Y'
            end
            at = Time.at(time).strftime(formatstr)
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

        if text =~ /^\001ACTION (.+)\001/
            text = "* #{nick} #{$1}"
        else
            text = "<#{nick}> #{text}"
        end
        "[#{at}] #{chan} #{text}"
    end
end
