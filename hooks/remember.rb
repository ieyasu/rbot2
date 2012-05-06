m = match_args(/([^\s=][^=]*)==\s*(\S.*)/, '<key> == <value>')
key, val = m[1].rstrip.downcase, m[2]

row = DB[:whatis].filter(:thekey => key).first
if row
  reply("#{row[:nick]} already taught me that #{row[:thekey]} == #{row[:value]}")
else
  DB[:whatis].insert(:thekey => key, :value => val, :nick => $msg.nick)
  reply("okay, #{key} == #{val}")
end
