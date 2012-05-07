require 'rubybot2/nextlib'

if (account = Account.name_by_nick($msg.nick))
  list = NextLib.list_undelivered(account)
  if Array === list
    i = 0
    list = list.map do |recips, message|
      i += 1
      "#{i}. #{recips}: #{NextLib.trunc message}"
    end.join(', ')
  end
  priv_reply list
else
  priv_reply("you need an account to list your unsent nexts")
end
