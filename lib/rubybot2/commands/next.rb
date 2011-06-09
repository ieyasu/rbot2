require 'rubybot2/nextlib'
require 'rubybot2/simple_account'

class Next
    NEXT_SYNTAX = 'Usage: !next <nick>([;,]<nick>...) <message>'
    DEL_SYNTAX = 'Usage: !deletenext'
    PAST_SYNTAX = 'Usage: !pastnexts [<count back> [<max to list>]]'
    MAX_RECIPS = 7

    def initialize(client)
    end

    # send a message to a recipient list next time they speak
    def c_next(msg, args, r)
        dest, message = args.split(nil, 2)
        raise '' if !message || dest[-1,1] =~ /[,;]/
        pats = dest.scan(/[^,;:]+/).uniq
        message = message.rstrip
        raise '' if pats.length < 1 || message.length == 0
        reply =
            if pats.length > MAX_RECIPS
                "you cannot next more than #{MAX_RECIPS} people at a time"
            else
                acct = DB.lock { |dbh| Account.by_nick(msg.nick, dbh) }
                NextLib.send(msg.nick, acct, pats, message)
            end
        r.priv_reply(reply)
    rescue RuntimeError
        r.priv_reply(NEXT_SYNTAX)
    end

    # read msg.nick's nexts
    def c_read(msg, args, r)
        NextLib.read(msg.nick, r, :report_none)
    end

    # list undelivered nexts
    def c_listnexts(msg, args, r)
        account = DB.lock { |dbh| Account.by_nick(msg.nick, dbh) } or return
        r.priv_reply(NextLib.list_undelivered(account))
    end

    # delete undelivered nexts
    def c_deletelastnext(msg, args, r)
        account = DB.lock { |dbh| Account.by_nick(msg.nick, dbh) } or return
        NextLib.del_last_undelivered(account, r)
    rescue ArgumentError # integer format trouble
        r.priv_reply(DEL_SYNTAX)
    end

    alias :c_deletenext :c_deletelastnext
    alias :c_delnext :c_deletelastnext

    # read already received nexts
    def c_pastnexts(msg, args, r)
        account = DB.lock { |dbh| Account.by_nick(msg.nick, dbh) } or return
        offset, limit = args.split(nil, 2)
        offset = offset ? Integer(offset) : -1
        limit = limit ? Integer(limit) : 5
        limit = 5 if limit < 1
        r.priv_reply(NextLib.list_delivered(account, offset, limit))
    rescue ArgumentError # integer format trouble
        r.priv_reply(PAST_SYNTAX)
    end
end
