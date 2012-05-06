match_args(/^[^\s=][^=]*$/, '<key>')

bykey = DB[:whatis].filter(:thekey => $args.downcase)
row = bykey.first
if row
  bykey.delete
  reply("forgot that #{row[:nick]} taught me #{row[:thekey]} == #{row[:value]}")
else
  reply("don't know about #{$args}")
end
