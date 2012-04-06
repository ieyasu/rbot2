match_args /[a-z].*/i, "<word>"
scrab_word = $args.strip.upcase
File.open("db/scrabbledict.txt") do |fin|
  fin.each_line do |line|
    if scrab_word == line.split(' :').first
      exit_reply "#{$args} is valid"
    end
  end
end
reply "#{$args} is invalid"
