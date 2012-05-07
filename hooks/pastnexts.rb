require 'rubybot2/nextlib'

m = match_args(/(\d+)?(?:\s+(\d+))?/, '[<count back> [<max to list>]]')
offset = (m[1] || 0).to_i
limit = (m[2] || 5).to_i
limit = 5 if limit < 1

if (account = Account.name_by_nick($msg.nick))
  msgs = NextLib.list_delivered(account, offset, limit)
  if msgs.length > 0
    i = offset
    nexts = msgs.map do |m|
      i += 1
      "#{i}. #{m[:message]}"
    end.join(', ')
    priv_reply nexts
  elsif offset > 0
    priv_reply 'your account has not received any nexts back that far'
  else
    priv_reply 'your account has not received any nexts'
  end
end
