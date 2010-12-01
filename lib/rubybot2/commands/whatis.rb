require 'rubybot2/db'

class Whatis
    WHATIS_SYNTAX    = 'Usage: !whatis <search terms>'
    REMEMBER_SYNTAX  = 'Usage: !remember <key> == <value>'
    MREMEMBER_SYNTAX = 'Usage: !mremember <key> == <value>'
    FORGET_SYNTAX    = 'Usage: !forget <key>'

    def initialize(client)
    end

    def c_whatis(msg, args, r)
        raise '' unless args.length > 0
        DB.lock do |dbh|
            rows = dbh.get("SELECT * FROM whatis WHERE regexp(thekey, ?) = 't'
                            ORDER BY LENGTH(thekey), thekey LIMIT 10;", args)
            if rows
                present_whatis(rows, r)
            else
                r.reply("#{args} not found")
            end
        end
    rescue RuntimeError
        r.reply(WHATIS_SYNTAX)
    end

    def c_remember(msg, args, r)
        do_remember(msg, args, r)
    rescue RuntimeError
        r.reply(REMEMBER_SYNTAX)
    end

    def c_mremember(msg, args, r)
        do_remember(msg, args, r, true)
    rescue RuntimeError
        r.reply(MREMEMBER_SYNTAX)
    end

    def c_forget(msg, args, r)
        raise '' unless args.length > 0
        args = args.downcase
        DB.lock do |dbh|
            row = dbh.row("SELECT * FROM whatis WHERE thekey = ? LIMIT 1;",
                          args)
            if row
                dbh.exec("DELETE FROM whatis WHERE thekey = ?;", args)
                r.reply("forgot that #{row[2]} taught me #{row[0]} == #{row[1]}")
            else
                r.reply("don't know about #{args}")
            end
        end
    rescue RuntimeError
        r.reply(FORGET_SYNTAX)
    end

    private

    def present_whatis(rows, r)
        res = rows.shift
        lines = res[1].split("{BR}")
        r.reply("#{res[2].strip} taught me that #{res[0]} == #{lines.shift}")
        lines.each { |line| r.reply(line) }
        if rows.length > 0
            rows = rows[0..4] + [['...']] if rows.length > 9
            r.reply("(also: #{rows.map {|a| a[0] }.join(', ')})")
        end
    end

    def do_remember(msg, args, r, multiline = false)
        raise '' unless args =~ /([^=]+)==\s*(\S.*)/
        key, val = $1.downcase.strip, $2
        DB.lock do |dbh|
            row = dbh.row("SELECT * FROM whatis WHERE thekey = ? LIMIT 1;",
                          key)
            if row
                exval = row[1].gsub('\\', '\\\\').gsub("\n", '\\n')
                r.reply("#{row[2]} already taught me that #{row[0]} == #{exval}")
            else
                val = val.gsub('\\n', "\n").gsub('\\\\', '\\') if multiline
                dbh.exec("INSERT INTO whatis VALUES(?,?,?);",
                         key, val.rstrip, msg.nick)
                r.reply("okay, #{key} == #{val}")
            end
        end
    end
end
