require 'rubybot2/account'

this_account = Account.by_nick($msg.nick)
m = match_args(this_account ? /^(\S+)?$/ : /^(\S+)$/, '<account-name>')
account = m[1] || this_account

accounts = DB[:nick_accounts].filter(:account => account).select_col(:nick)
if accounts.length > 0
  reply("account #{account} has the nicks: #{accounts.join(', ')}")
elsif Account.exists?(account)
  reply("account #{account} has no nicks")
else
  reply("account #{account} does not exist")
end
