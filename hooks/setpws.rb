require 'rubybot2/account'

priv_reply("Sets a more localized personal weather station ID for !w.   For example, KCAVALLE34.")
m = match_args(/^(\S+)\s+(\S+)$/, '<pws> <password>')
pws, pass = m[1], m[2]

account = Account.ds_by_nick($msg.nick)
if Account.check_passwd(account, pass, $rep)
  account.update(:pws => pws)
  priv_reply("PWS station ID updated to #{pws}")
end
