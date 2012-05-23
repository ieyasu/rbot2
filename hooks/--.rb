m = match_args(/(\S+)/, '<thing>')
what = m[1].downcase
q = DB[:points].filter(:thing => what)
row = q.first
if row
  points = row[:points] - 1
  q.update(:points => points)
else
  points = -1
  DB[:points].insert(:thing => what, :points => points)
end
reply "#{what} has #{points} points"
