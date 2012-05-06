require 'rubybot2/nextlib'
MAX_RECIPS = 7

m = match_args(/([^,;:\s]+:?(?:[,;][^,;:\s]+:?)*)\s+(\S.*)/,
          '<nick>([;,]<nick>...) <message>')
pats = m[1].scan(/[^,;:]+/).uniq
message = m[2].rstrip

if pats.length <= MAX_RECIPS
  acct = Account.name_by_nick($msg.nick)
  priv_reply NextLib.send($msg.nick, acct, pats, message)
else
  priv_reply "you cannot next more than #{MAX_RECIPS} people at a time"
end
