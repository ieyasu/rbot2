require 'rubybot2/nextlib'

if (account = Account.name_by_nick($msg.nick))
  priv_reply(NextLib.list_undelivered(account))
else
  priv_reply("you need an account to list your unsent nexts")
end
