require 'rubybot2/account'

m = match_args(/^(\S+)\s+(\S+)$/, '<old-pass> <new-pass>')
oldpass, newpass = m[1], m[2]

account = Account.ds_by_nick($msg.nick)
if Account.check_passwd(account, oldpass, $rep)
  account.update(:passwd => Account.hash_passwd(newpass))
  priv_reply("password updated")
end
