require 'rubybot2/account'

m = match_args(/^(\S+)\s+(\S+)$/, '<account-name> <password>')
account, pass = m[1], m[2]

if Account::check_passwd(account, pass, $rep)
  na = DB[:nick_accounts].filter(:nick => $msg.nick, :account => account)
  case na.delete
  when 1
    priv_reply("removed nick #{$msg.nick} from account #{account}")
  when 0
    priv_reply("account #{account} does not own nick #{$msg.nick}")
  else
    raise "AIEEE Shouldn't be able to delete that many"
  end
end
