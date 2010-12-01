require 'rubybot2/db'

module Account
    # Remember to aquire the database lock first (DB.lock).
    def Account.by_authed_nick(nick, dbh)
        dbh.cell("SELECT account FROM nick_accounts WHERE
                  nick = ? AND authed = 1;", nick)
    end

    # Remember to aquire the database lock first (DB.lock).
    def Account.zip_by_nick(nick, dbh)
        dbh.cell("SELECT accounts.zip FROM accounts INNER JOIN nick_accounts
                  ON nick_accounts.account = accounts.name
                  WHERE nick_accounts.nick = ?;", nick)
    end
end
