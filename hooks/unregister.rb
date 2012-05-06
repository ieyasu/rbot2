require 'rubybot2/account'

m = match_args(/^(\S+)\s+(\S+)$/, '<account-name> <password>')
account, pass = m[1], m[2]

if Account::check_passwd(account, pass, $rep)
  Account::destroy(account)
  priv_reply("deleted account #{account} and any registered nicks; if you didn't mean to do this, pray to Marduk that the admin has backups")
end
