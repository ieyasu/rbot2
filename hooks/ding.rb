m = match_args(/(.+)/, '<level>')
DB[:levels].filter(:nick.like("#{$msg.nick}%")).delete
DB[:levels].insert(:nick => $msg.nick, :level => m[1])
reply "#{$msg.nick} is #{m[1]}"
