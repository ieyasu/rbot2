require 'rubybot2/account'

this_account = Account.by_nick($msg.nick)
m = match_args(this_account ? /^(\S+)?$/ : /^(\S+)$/, '<account-name>')
account = m[1] || (this_account && this_account[:name])

nicks = DB[:nick_accounts].filter(:account => account).select_col(:nick)
if nicks.length > 0
  reply("account #{account} has the nicks: #{nicks.join(', ')}")
elsif Account.exists?(account)
  reply("account #{account} has no nicks")
else
  reply("account #{account} does not exist")
end
