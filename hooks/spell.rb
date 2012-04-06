require 'raspell'

def google_suggest(args)
    body = http_get("http://www.google.com/search?lr=lang_en&q=#", $args)
    i = body.index('Did you mean') or return []
    i = body.index('<i>', i) or return []
    j = body.index('</i>', i) or return []
    strip_html(body[i...j])
end

match_args /\S+/, '<word>'

spell = Aspell.new
if spell.check($args)
  reply "#{$args} is spelled correctly"
else
  sugg = spell.suggest($args).join(', ') || google_suggest($args)
  reply "#{$args} is misspelled; suggestions: #{sugg}"
end
