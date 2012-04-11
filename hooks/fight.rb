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
  body =~ /([\d,]+)\s*results/i or return 0
  $1.gsub(',', '').to_i
end

m = match_args /(.+)\s+(?:versus|vs\.?|:)\s+(.*)/, '<item 1> vs <item 2>'
items = m[1], m[2]

counts = items.map do |item|
  item = CGI.escape(item.strip)
  parse_count(http_get("http://www.google.com/search?hl=en&q=#", item))
end

if (result = get_victor(items, counts))
  reply result
else
  reply "error parsing fight results"
end
