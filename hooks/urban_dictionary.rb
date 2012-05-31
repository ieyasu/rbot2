MAX_OUTPUT_SIZE = 1000

def parse_definitions(body)
  return if body.index("i> isn't defined")
  i = 0
  ary = []
  size = 0
  while (i = body.index(%r!<div class=['"]definition['"]!i, i))
    j = body.index(%r!</div!, i)
    definition =  strip_html(body[i...j])
    size += definition.length
    ary << definition
    break if ary.length > 0 && size > MAX_OUTPUT_SIZE
    i = j
  end
  ary
end

match_args /\w+/, '<word>'

body = http_get("http://www.urbandictionary.com/define.php?term=#", $args)
if (ary = parse_definitions(body))
  if ary.length > 0
    ary.each_with_index do |r, i|
      reply "#{i + 1}. #{r}"
    end
  else
    reply "error parsing definition for #{$args}"
  end
else
  reply "whoa there hep cat, your jive is too fresh for urban dictionary!"
end
