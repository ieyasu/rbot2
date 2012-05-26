require 'rubybot2/nextlib'

if (account = Account.name_by_nick($msg.nick))
  list = NextLib.list_undelivered(account)
  if Array === list
    i = 0
    list = list.map do |nxt|
      i += 1
      "#{i}. #{nxt[:recips]}: #{NextLib.trunc nxt[:msg]}"
    end.join(', ')
  end
  priv_reply list
else
  priv_reply("you need an account to list your unsent nexts")
end
