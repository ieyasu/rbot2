require 'rubybot2/db'

class Whatis
    WHATIS_SYNTAX    = 'Usage: !whatis <search terms>'
    REMEMBER_SYNTAX  = 'Usage: !remember <key> == <value>'
    FORGET_SYNTAX    = 'Usage: !forget <key>'

    def initialize(client)
    end

    def c_whatis(msg, args, r)
        raise '' unless args.length > 0
        rows = DB[:whatis].all_regex(:thekey, args).
            sort_by {|row| row[:thekey].length}[0...10]
        if rows.length > 0
            present_whatis(rows, r)
        else
            r.reply("#{args} not found")
        end
    rescue RuntimeError
        r.reply(WHATIS_SYNTAX)
    end

    def c_remember(msg, args, r)
        raise '' unless args =~ /([^=]+)==\s*(\S.*)/
        key, val = $1.downcase.strip, $2
        row = DB[:whatis].filter(:thekey => key).first
        if row
            r.reply("#{row[:nick]} already taught me that #{row[:thekey]} == #{row[:value]}")
        else
          DB[:whatis].insert(:thekey => key, :value => val.rstrip,
                             :nick => msg.nick)
                r.reply("okay, #{key} == #{val}")
            end
    rescue RuntimeError
        r.reply(REMEMBER_SYNTAX)
    end

    def c_forget(msg, args, r)
        raise '' unless args.length > 0
        args = args.downcase
        bykey = DB[:whatis].filter(:thekey => args)
        row = bykey.first
        if row
          bykey.delete
          r.reply("forgot that #{row[:nick]} taught me #{row[:thekey]} == #{row[:value]}")
        else
            r.reply("don't know about #{args}")
        end
    rescue RuntimeError
        r.reply(FORGET_SYNTAX)
    end

    private

    def present_whatis(rows, r)
        res = rows.shift
        lines = res[:value].split("{BR}")
        r.reply("#{res[:nick].strip} taught me that #{res[:thekey]} == #{lines.shift}")
        lines.each { |line| r.reply(line) }
        if rows.length > 0
            rows = rows[0..4] + [{:thekey => '...'}] if rows.length > 9
            r.reply("(also: #{rows.map {|a| a[:thekey] }.join(', ')})")
        end
    end
end
