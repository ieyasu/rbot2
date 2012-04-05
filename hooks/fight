#!/usr/bin/env ruby

SYNTAX = 'Usage: !fight <item 1> vs <item 2>'

def random_victory(n1, n2)
  ["WINS!", "wins!", "is the victor!", "triumphs!"][rand(4)]
end

# space out at thousands mark
def st(value)
  value = value.to_s
  while (value =~ /\d{4,}\b/)
    value = value.sub(/(\d{3})\b/, " \\1")
  end
  value.lstrip
end

def get_victor(items, counts)
  if (counts[0] - counts[1]).abs / counts[1].to_f < 0.2
    "#{items[0]} and #{items[1]} are pretty much tied (#{st counts[0]} vs #{st counts[1]})"
  else
    item = counts[0] > counts[1] ? items[0] : items[1]
    "#{item} #{random_victory(*counts)} (#{st counts[0]} vs #{st counts[1]})"
  end
end

def parse_count(body)
  body =~ /<div id=resultStats>About ([\d,]+)/ or return 0
  $1.gsub(',', '').to_i
end

def parse_args(args)
  items = args.split
  if items.length != 2
    sargs = args.split(/ (?:versus|vs\.?|:) /, 2)
    return sargs if sargs && sargs.length == 2
  else
    return items
  end
end

def handle_command(nick, dest, args)
  items = parse_args(args)
  return "P\t#{SYNTAX}" unless items

  counts = items.map do |item|
    item = CGI.escape(item.strip)
    parse_count(read_url("http://www.google.com/search?hl=en&q=#{item}"))
  end

  if (result = get_victor(items, counts))
    "P\t#{result}"
  else
    "P\terror parsing fight results"
  end
end

load 'boilerplate.rb'
