who = ($args =~ /(\S+)/) ? $1 : $msg.nick
q =
  if (account = Account.name_by_nick(who))
    who = account
    DB[:levels].filter(account: account)
  else
    DB[:levels].filter(nick: who)
  end
if (l = q.first)
  reply "#{who} is #{l[:level]}"
else
  reply "#{who} has no level"
end
