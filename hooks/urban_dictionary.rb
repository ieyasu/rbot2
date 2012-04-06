MAX_OUTPUT_SIZE = 1000

def parse_definitions(body)
  return if body.index('</b> is undefined.')
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
  ary if ary.length > 0
end

match_args /\w+/, '<word>'

body = http_get("http://www.urbandictionary.com/define.php?term=#", $args)
if (ary = parse_definitions(body))
  ary.each_with_index do |r, i|
    reply "#{i + 1}. #{r}"
  end
else
  reply "error parsing definition for #{$args}"
end
