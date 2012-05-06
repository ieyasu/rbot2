require 'rubybot2/account'

begin
  m = match_args(/^(\S+)\s+(\S+)$/, '<account-name> <password>')
  account, pass = m[1], m[2]

  if Account::check_passwd(account, pass, $rep)
    DB[:nick_accounts].insert($msg.nick, account)
    priv_reply("added nick #{$msg.nick} to account #{account}")
  end
rescue Sequel::DatabaseError
  priv_reply("someone else has already added the nick #{$msg.nick} to their account")
end
