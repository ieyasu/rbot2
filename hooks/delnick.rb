require 'rubybot2/account'

m = match_args(/^(\S+)\s+(\S+)$/, '<account-name> <password>')
account, pass = m[1], m[2]

if Account::check_passwd(account, pass, $rep)
  succ, msg = Account::del_nick(account, $msg.nick)
  priv_reply(msg)
end
