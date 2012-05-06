require 'rubybot2/account'

m = match_args(/^(\S+)\s+(\S+)$/, '<account-name> <password>')
account, pass = m[1], m[2]

if Account::exists?(account)
  priv_reply("account #{account} already exists")
else
  DB[:accounts].insert(account, $rbconfig['default-zip'], Account::hash_passwd(pass))
  priv_reply("created account #{account} for you; now add nicks with the addnick command")
end
