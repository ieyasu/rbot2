MAX_LINES = 3
CORRECTIONS = {/<br\s?\/>/ => ''}

doc = noko_get('http://bash.org/?random')
quote = (doc/'p.qt')
if quote.empty?
  put "no quotes found :("
else
  quote = quote.first.inner_html
  CORRECTIONS.each do |regex, replacement|
    quote.gsub! regex, replacement
  end
  quote = CGI.unescapeHTML(quote)
  quote = quote.split(/\r\n/).compact
  quote_id = (doc/'p.quote/a').first['href']
  if quote.size > MAX_LINES
    quote = quote[0..(MAX_LINES-2)]
    quote << "[...] more at http://bash.org/#{quote_id}"
  end

  quote.each {|q| reply q}
end
