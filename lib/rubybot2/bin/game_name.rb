#!/usr/bin/env ruby

MAX = 15

def read_names
    cols = []
    col = 0
    File.open('db/video_game_names.txt') do |fin|
        fin.each_line do |line|
	    case line
	    when /\A----/
	        col += 1
	    else
	        (cols[col] ||= []) << line.strip
	    end
	end
    end
    cols
end

def r(ary)
    ary[rand(ary.length)]
end

def select_phrase(cols)
    ary = cols.map { |col| r(col) }
    n = ary.inject(0) { |count, word| word[0..0] == '*' ? count + 1 : count }
    select_phrase(cols) if n > 1
    ary.map { |word| word[0..0] == '*' ? word[1..-1] : word }.join(' ')
end

def handle_command(nick, dest, args)
    cols = read_names
    begin
    	n = Integer(args)
	n = MAX if n > MAX
	s = (1..n).map { |i| select_phrase(cols) }.join(' // ')
	"P\t#{s}"
    rescue ArgumentError
        phrase = select_phrase(cols)
        "P\t#{phrase}"
    end
end

load 'boilerplate.rb'
