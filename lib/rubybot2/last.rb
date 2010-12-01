require 'rubybot2/db'

module Last
    def Last.statement(nick, chan)
        sql = 'SELECT * FROM last '
        if nick || chan
            sql << 'WHERE '
            sql << "regexp(nick, ?) = 't'" if nick
            sql << ' AND ' if nick && chan
            sql << 'chan = ?' if chan
        end
        sql << 'ORDER BY at DESC LIMIT 1;'

        args =
            if nick && chan
                [sql, nick, chan]
            elsif nick
                [sql, nick]
            elsif chan
                [sql, chan]
            else
                [sql]
            end
        DB.lock { |dbh| dbh.row(*args) }
    end

    def Last.update(nick, chan, text)
        DB.lock do |dbh|
            dbh.exec('INSERT OR REPLACE INTO last VALUES(?, ?, ?, ?);',
                     nick, chan, text, Time.now.to_i)
        end
    end
end
