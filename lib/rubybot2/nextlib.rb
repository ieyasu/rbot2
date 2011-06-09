require 'rubybot2/db'

module NextLib
  # Inserts entries into the database for a next from the given nick and
  # account, to the nick patterns in the pats array, to send the text in
  # message.
  def NextLib.send(from_nick, from_account, pats, msg)
    accounts, nick_pats = NextLib.recipients(from_account, pats)
    nps, aps = NextLib.format_recips(nick_pats, accounts)
    # insert 'em; dupes fail silently to reduce abuse
    id = DB[:nexts].insert(nil, Time.now.to_i, from_nick, from_account, msg)
    if id
      accounts.each do |account|
        oa = (accounts - [account]).join(';')
        oa = "(#{oa})" if oa.length > 0
        DB[:account_recips].insert(id, account, nps + oa)
      end
      nick_pats.each do |pat|
        op = (nick_pats - [pat]).join(';')
        DB[:pattern_recips].insert(id, pat, op + aps)
      end
    end
    # success reply
    return "will send `#{message}` to #{nps}#{aps}"
  end

  # Reads the undelivered nexts for the given nick, delivering them
  # using r, a Replier object.
  def NextLib.read(nick, r, report_none = false)
    ary = NextLib.check(nick) and
      ary.each { |msg| r.priv_reply(msg) }
    if !ary && report_none
      r.priv_reply('you have no nexts')
    end
  end

  # Returns a list of undelivered nexts sent by the given account,
  # numbering starting with 0.
  def NextLib.list_undelivered(from_account)
    nxts = DB[:nexts].filter(:account => account).order(:sent_at.desc).limit(8)
    return 'you have no undelivered nexts' unless nxts.length > 0
    i = -1
    nxts.map do |nxt|
      ar = DB[:account_recips].filter(:next_id => nxt[:id]).select_col(:account)
      pr = DB[:pattern_recips].filter(:next_id => nxt[:id]).select_col(:nick_pat)
      ar, pr = NextLib.format_recips(ar, pr)
      i += 1
      "#{i}. #{ar}#{pr}: `#{NextLib.trunc message}`"
    end.join(', ')
  end

  # Deletes the last undelivered next sent by the specified account.
  def NextLib.del_last_undelivered(account, r)
    nxt = DB[:nexts].filter(:from_account => account).order(:sent_at).last
    if nxt
      nid = nxt[:id]
      DB[:nexts].filter(:id => nid).delete
      DB[:account_recips].filter(:next_id => nid).delete
      DB[:pattern_recips].filter(:next_id => nid).delete
      r.priv_reply("deleted last undelivered next '#{NextLib.trunc nxt[:message]}'")
    else
        r.priv_reply("no undelivered nexts to delete")
    end
  end

  # Lists delivered nexts sent to the given account. The specified count
  # and limit are for specifying the subset of nexts to return.
  def NextLib.list_delivered(account, offset, limit)
    msgs = DB[:received_nexts].filter(:account => account).
      order(:recvd_at.desc).limit(limit, offset).all
    if msgs.length > 0
      i = (offset < 0 ? 0 : offset) - 1
      msgs.map do |m|
        i += 1
        time = Time.at(m[:recvd_at]).strftime('%a %Y-%m-%d %H:%M')
        "#{i}. [#{time}] #{m[:message]}"
      end.join('; ')
    elsif offset > 0
      'your account has not received any nexts back that far'
    else
      'your account has not received any nexts'
    end
  end

  private

  # Matches nick patterns to accounts, sorting patterns into account
  # recipients and regex recipients.
  def NextLib.recipients(from_account, pats)
    accounts,nick_pats = [],[]
    pats.map do |pat|
      na = DB[:nick_accounts].filter_regex(:nick, pat).first
      if na
        accounts << na[:account]
      else
        nick_pats << pat
      end
    end
    return accounts.uniq, nick_pats
  end

  def NextLib.check(nick)
    account = Account.name_by_authed_nick(nick).first
    ar = DB[:account_recips].filter(:account => account).all
    pr = DB[:pattern_recips].filter_regex(:nick_pat, nick)
    recips = ar.concat(pr)
    ids = recips.map {|r| r[:next_id]}
    nexts = DB[:nexts].filter(:id => ids)
    # format nexts, store for accounts, and return
    now = Time.now.to_i
    recips.map do |recip|
      nid = recip[:next_id]
      nxt = nexts.find {|n| n[:id] == nid}
      f = NextLib.format(nxt, recip)
      if (account = recip[:account])
        DB.run("INSERT OR IGNORE INTO received_nexts VALUES(?,?,?,?);",
               account, sent_at, now, f)
        DB[:account_recips].filter(:next_id => nid, :account => account).delete
      end
      DB[:pattern_recips].filter(:next_id => nid).
        filter(:nick_pat => pr.map {|row| row[:nick_pat]}).delete
      DB[:nexts].filter(:id => nid).delete
      f
    end
 end

  def NextLib.format(nxt, recip)
    other_recips = "#{recip[:other_recips]} " if recip[:other_recips].length > 0
    sent_time = Time.at(nxt[:sent_at])
    timef = '%a %H:%M'
    timef = '%b ' + timef if sent_time < (Time.now - (30 * 24 * 60 * 60))
    timef = '%Y ' + timef if sent_time < (Time.now - (365 * 24 * 60 * 60))
    time = sent_time.strftime(timef)
    pat = recip[:nick_pat] || recip[:account]
    "[#{time}] #{other_recips}\2#{pat}\2: <#{nxt[:from_nick]}> #{nxt[:message]}"
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
end
