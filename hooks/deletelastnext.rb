require 'rubybot2/nextlib'

if (account = Account.name_by_nick($msg.nick))
  NextLib.del_last_undelivered(account, $rep)
else
  priv_reply('you need an account to delete sent nexts')
end
