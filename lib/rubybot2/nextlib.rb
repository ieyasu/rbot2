require 'rubybot2/simple_account'

module NextLib
    # Inserts entries into the database for a next from the given nick and
    # account, to the nick patterns in the pats array, to send the text in
    # message.
    def NextLib.send(from_nick, from_account, pats, message)
        DB.lock do |dbh|
            accounts, nick_pats = NextLib.recipients(from_account, pats, dbh)
            nps, aps = NextLib.format_recips(nick_pats, accounts)
            # insert 'em; dupes fail silently to reduce abuse
            dbh.exec("INSERT INTO nexts VALUES(NULL,?,?,?,?);",
                     Time.now.to_i, from_nick, from_account, message)
            if (liri = dbh.last_insert_row_id)
                accounts.each do |account|
                    oa = (accounts - [account]).join(';')
                    oa = "(#{oa})" if oa.length > 0
                    dbh.exec("INSERT INTO account_recips VALUES(?,?,?);",
                             liri, account, nps + oa)
                end
                nick_pats.each do |pat|
                    op = (nick_pats - [pat]).join(';')
                    dbh.exec("INSERT INTO pattern_recips VALUES(?,?,?);",
                             liri, pat, op + aps)
                end
            end
            # check if any recipients should be emailed
            NextLib.check_next_overflow(dbh)
            # success reply
            return "will send `#{message}` to #{nps}#{aps}"
        end
    end

    # Reads the undelivered nexts for the given nick, delivering them
    # using r, a Replier object.
    def NextLib.read(nick, r, report_none = false)
        DB.lock do |dbh|
            ary = NextLib.check(nick, dbh) and
                ary.each { |msg| r.priv_reply(msg) }
            if NextLib.nexts_waiting?(nick, dbh)
                r.priv_reply('you have next(s) which require authentication; please authenticate')
            elsif !ary && report_none
                r.priv_reply('you have no nexts')
            end
        end
    end

    # Returns a list of undelivered nexts sent by the given account,
    # numbering starting with 0.
    def NextLib.list_undelivered(from_account)
        DB.lock do |dbh|
            nexts = dbh.get("SELECT * FROM nexts WHERE from_account = ?
                             ORDER BY sent_at DESC LIMIT 8;", from_account)
            return 'you have no undelivered nexts' unless nexts
            i = -1
            nexts.map do |id, sent_at, from_nick, from_account, message|
                ar = dbh.cells("SELECT account FROM account_recips
                                WHERE next_id = ?;", id) || []
                pr = dbh.cells("SELECT nick_pat FROM pattern_recips
                                WHERE next_id = ?;", id) || []
                ar, pr = NextLib.format_recips(ar, pr)
                i += 1
                "#{i}. #{ar}#{pr}: `#{NextLib.trunc message}`"
            end.join(',  ')
        end
    end

    # Deletes the last undelivered next sent by the specified account.
    def NextLib.del_last_undelivered(account, r)
        DB.lock do |dbh|
            id, msg = dbh.row("SELECT ROWID, message FROM nexts
                               WHERE from_account = ?
                               ORDER BY sent_at DESC LIMIT 1;", account)
            if id
                dbh.exec("DELETE FROM nexts WHERE id = ?;", id)
                dbh.exec("DELETE FROM account_recips WHERE next_id = ?;", id)
                dbh.exec("DELETE FROM pattern_recips WHERE next_id = ?;", id)
                r.priv_reply("deleted last undelivered next '#{NextLib.trunc msg}'")
            else
                r.priv_reply("no undelivered nexts to delete")
            end
        end
    end

    # Lists delivered nexts sent to the given account.  The specified count
    # and limit are for specifying the subset of nexts to return.
    def NextLib.list_delivered(account, offset, limit)
        msgs =
            DB.lock do |dbh|
                dbh.get("SELECT recvd_at, message FROM received_nexts
                         WHERE account = ? ORDER BY recvd_at DESC
                         LIMIT ? OFFSET ?;", account, limit, offset)
            end
        if msgs
            i = (offset < 0 ? 0 : offset) - 1
            msgs.map do |recvd_at, msg|
                i += 1
                time = Time.at(recvd_at).strftime('%a %Y-%m-%d %H:%M')
                "#{i}. [#{time}] #{msg}"
            end.join(';  ')
        elsif offset > 0
            'your account has not received any nexts back that far'
        else
            'your account has not received any nexts'
        end
    end

    private

    # Matches nick patterns to accounts, sorting patterns into account
    # recipients and regex recipients.
    def NextLib.recipients(from_account, pats, dbh)
        accounts,nick_pats = [],[]
        pats.map do |pat|
            ary = dbh.cells("SELECT account FROM nick_accounts WHERE
                             regexp(nick, ?) = 't' GROUP BY account;", pat)
            if ary && ary.length == 1 && ary.first != from_account
                accounts << ary.first
            else
                nick_pats << pat
            end
        end
        return accounts.uniq, nick_pats
    end

    def NextLib.nexts_waiting?(nick, dbh)
        dbh.cell("SELECT COUNT(*) FROM account_recips INNER JOIN nick_accounts
                      ON nick_accounts.account = account_recips.account
                      WHERE nick = ?;",
                 nick).to_i > 0
    end

    def NextLib.check(nick, dbh)
        NextLib.check2(nick, Account.by_authed_nick(nick, dbh), dbh)
    end

    def NextLib.check_account(account, dbh)
        nick = dbh.cell("SELECT nick FROM nick_accounts WHERE account = ?
                         LIMIT 1;", account) or return
        NextLib.check2(nick, account, dbh)
    end

    def NextLib.check2(nick, account, dbh)
        recips = dbh.get("SELECT * FROM account_recips WHERE account = ?
                          UNION
                          SELECT * FROM pattern_recips
                              WHERE regexp(?, nick_pat) = 't';",
                         account, nick) or return
        ids = recips.map { |r| r.first }.uniq.join(', ')
        nexts = dbh.get("SELECT id, sent_at, from_nick, message FROM nexts
                         WHERE id IN (#{ids});") or return
        # format nexts, store for accounts, and return
        now = Time.now.to_i
        recips.map do |next_id, dest, other_recips|
         rowid, sent_at, from_nick, message = nexts.assoc(next_id.to_i)
            f = NextLib.format(sent_at, from_nick, dest, other_recips,
                               message)
            if account
                dbh.exec("INSERT OR IGNORE INTO received_nexts VALUES(?,?,?,?);",
                         account, sent_at, now, f)
                dbh.exec("DELETE FROM account_recips
                          WHERE next_id = ? AND account = ?;", rowid, account)
            end
            dbh.exec("DELETE FROM pattern_recips
                      WHERE next_id = ? AND regexp(?, nick_pat) = 't';",
                     rowid, nick)
            if dbh.cell("SELECT COUNT(*) FROM (
                             SELECT next_id FROM account_recips
                                 WHERE next_id = ?
                             UNION
                             SELECT next_id FROM pattern_recips
                                 WHERE next_id = ?);", rowid, rowid).to_i == 0
                dbh.exec("DELETE FROM nexts WHERE id = ?;", rowid)
            end
            f
        end
    end

    def NextLib.format(sent_at, from_nick, pat, other_recips, msg)
        other_recips = "#{other_recips} " if other_recips.length > 0
        sent_time = Time.at(sent_at)
        timef = '%a %H:%M'
        timef = '%b ' + timef if sent_time < (Time.now - (30 * 24 * 60 * 60))
        timef = '%Y ' + timef if sent_time < (Time.now - (365 * 24 * 60 * 60))
        time = sent_time.strftime(timef)
        "[#{time}] #{other_recips}\2#{pat}\2: <#{from_nick}> #{msg}"
    end

    def NextLib.format_recips(pattern_recips, account_recips)
        pr = pattern_recips.join(', ')
        ar = account_recips.join(', ')
        if ar.length > 0
            ar = "(#{ar})"
            ar = " #{ar}" if pr.length > 0
        end
        return pr, ar
    end

    def NextLib.trunc(s)
        return s if s.length < 60
        i = s.rindex(' ', 20) || 20
        d = s.length - 60
        j = s.rindex(' ', d) || d
        "#{s[0...i]}...#{s[j + 1..-1]}"
    end

    MAX_NUM_NEXTS = 13
    MAX_NEXT_WAIT = 11 * 24 * 60 * 60

    # If there are too many nexts or any next has been waiting around
    # too long for an account with an email address, mark those messages
    # as read and email them off to the recorded address.
    def NextLib.check_next_overflow(dbh)
        ary = dbh.get("SELECT nexts.id, account FROM nexts
                       INNER JOIN account_recips ON nexts.id = next_id
                       WHERE sent_at < ? OR account IN (
                           SELECT account FROM account_recips
                           GROUP BY account
                           HAVING COUNT(*) > ?);",
                      Time.now.to_i - MAX_NEXT_WAIT, MAX_NUM_NEXTS) or return
        ary.each do |next_id, account|
            email = dbh.cell("SELECT email FROM accounts WHERE name = ?;",
                             account) or next
            ary = NextLib.check_account(account, dbh) or next
            NextLib.send_overflow(account, email, ary.join("\n\n"))
        end
    end

    # Uses the sendmail binary to send mail to the given recipient
    def NextLib.send_overflow(to, email, body)
        IO.popen('sendmail -i -t', 'w') do |io|
            io.puts(<<eod
To: "#{to}" <#{email}>
Subject: Rubybot Next Backlog

Your IRC nexts have been accumulating for too long.  Because your account
has an email address in the preferences, this backlog of nexts has been
sent to you at that email address.  These messages have also been
archived.  If you wish to read them from IRC, you can use the !pastnexts
command.

eod
)
            io.puts(body)
        end
    end
end
