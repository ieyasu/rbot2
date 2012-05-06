m = match_args(/\S.*/, '<search terms>')

rows = DB[:whatis].all_regex(:thekey, $args).
  sort_by {|row| row[:thekey].length}[0...10]
if rows.length > 0
  res = rows.shift
  lines = res[:value].split("{BR}")
  reply("#{res[:nick].strip} taught me that #{res[:thekey]} == #{lines.shift}")
  lines.each { |line| r.reply(line) }
  if rows.length > 0
    rows = rows[0..4] + [{:thekey => '...'}] if rows.length > 9
    reply("(also: #{rows.map {|a| a[:thekey] }.join(', ')})")
  end
else
  reply("#{$args} not found")
end
