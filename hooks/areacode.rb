MAX_LINES = 5

match_args /\S+/, '<code> | <location>'

pat = Regexp.new($args, Regexp::IGNORECASE)
n_results = 0
each_line('db/area_codes') do |line|
  if line =~ pat
    n_results += 1
    reply line if n_results <= MAX_LINES
  end
end

if n_results == 0
  if $args =~ /^\d{3}$/
    reply "Unknown areacode #{$args}"
  else
    reply "No areacode for #{$args}"
  end
elsif n_results > MAX_LINES
  reply "Last #{n_results - MAX_LINES} results elided"
end
