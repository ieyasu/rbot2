m = match_args(/(.*)/, '<args>')
reply "you said #{$args}"
priv_reply "matched: #{m.inspect}"
priv_reply "your zip is #{ENV['ZIP']}"
action 'away!'
