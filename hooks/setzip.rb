require 'rubybot2/account'

m = match_args(/^(\S+)\s+(\S+)$/, '<zip> <password>')
zip, pass = m[1], m[2]

account = Account.ds_by_nick($msg.nick)
if Account.check_passwd(account, pass, $rep)
  account.update(:zip => zip)
  priv_reply("zip updated to #{zip}")
end
