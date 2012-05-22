who = $args.length > 0 ? $args : $msg.nick
l = DB[:levels].filter(:nick.like(who + '%')).first
if l
  reply l[:level]
else
  reply "#{who} not found"
end
