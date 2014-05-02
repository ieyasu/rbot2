m = match_args(/(\S+)/) do
  top = DB[:points].order(Sequel.desc(:points)).limit(1).first
  best = top ? "#{top[:thing]} = #{top[:points]}" : ''
  bot = DB[:points].order(:points).limit(1).first
  worst = bot ? "#{bot[:thing]} = #{bot[:points]}" : ''
  "<thing>; best: #{best}, worst: #{worst}"
end
what = m[1].downcase
thing = DB[:points].filter(:thing => what).first
points = thing ? thing[:points] : 0
reply "#{what} has #{points} points"
