require 'rubybot2/nextlib'

m = match_args(/(\d+)?(?:\s+(\d+))?/, '[<count back> [<max to list>]]')
offset = (m[1] || 0).to_i
limit = (m[2] || 5).to_i
limit = 5 if limit < 1

if (account = Account.name_by_nick($msg.nick))
  priv_reply NextLib.list_delivered(account, offset, limit)
else
  priv_reply "you need an account to list received nexts"
end
