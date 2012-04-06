MAX = 15

def read_names
  cols = []
  col = 0
  each_line('db/video_game_names.txt') do |line|
    case line
    when /\A----/
      col += 1
    else
      (cols[col] ||= []) << line.strip
    end
  end
  cols
end

def select_phrase(cols)
  ary = cols.map { |col| r(col) }
  n = ary.inject(0) { |count, word| word[0..0] == '*' ? count + 1 : count }
  select_phrase(cols) if n > 1
  ary.map { |word| word[0..0] == '*' ? word[1..-1] : word }.join(' ')
end

cols = read_names
begin
  n = Integer($args)
  n = MAX if n > MAX
  reply (1..n).map { |i| select_phrase(cols) }.join(' // ')
rescue ArgumentError
  reply select_phrase(cols)
end
