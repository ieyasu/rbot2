def parse_quote(body, symbol)
  i = body.index('Last Price') or return
  i = body.index('<td', i + 14) or return
  j = body.index('</td', i) or return
  price = strip_html(body[i...j])
  #p price

  if price =~ /N\/A/
    return "Stock symbol #{symbol} not found"
  end

  i = body.index('Change</td>') or return
  i = body.index('<td', i + 11) or return
  j = body.index("</td", i) or return
  change = strip_html(body[i...j])
  change = '+' + change if change[0..0] != '-'
  #p change

  i = body.index('% Change</td>') or return
  i = body.index('<td', i + 13) or return
  j = body.index("</td", i) or return
  changepc = strip_html(body[i...j])
  changepc = '+' + changepc if change[0..0] != '-'
  changepc = "(#{changepc})"
  #p changepc

  i = body.index(/Last (?:Trade|Update)<\/td/) or return
  i = body.index('<td', i + 12) or return
  j = body.index('</td', i) or return
  time = strip_html(body[i...j])
  #p time

  "#{symbol.upcase}: #{price}  #{change} #{changepc}  closed #{time}"
end

match_args /\S+/, '<symbol>'

body = http_get("http://mobile.quote.com/quotes.aspx?symbol=#", $args)

if (quote = parse_quote(body, args))
    reply quote
else
  reply "error parsing quote for #{$args}"
end
