m = match_args(/(.+)/, '<level>')
if (account = Account.name_by_nick($msg.nick))
  DB[:levels].filter(:account => account).delete
  DB[:levels].insert(:account => account, :level => m[1])
  reply "account #{account} is #{m[1]}"
else
  DB[:levels].filter(:nick => $msg.nick).delete
  DB[:levels].insert(:nick => $msg.nick, :level => m[1])
  reply "#{$msg.nick} is #{m[1]}"
end
