POS_MAP = {
  'noun'         => 'n',
  'pronoun'      => 'pro',
  'verb'         => 'v',
  'adjective'    => 'adj',
  'adverb'       => 'adv',
  'preposition'  => 'prep',
  'conjunction'  => 'conj',
  'interjection' => 'int'
}

def parse_html(body, word)
  if body.index('no thesaurus results')
    return "#{word} not found"
  end

  i = body.index('Main Entry:') or return
  i = body.index('<span', i) or return
  j = body.index('</span', i) or return
  word = strip_html(body[i...j])
  #p word

  i = body.index('Part of Speech:', j) or return
  i = body.index('<td', i) or return
  j = body.index('</td', i) or return
  s = strip_html(body[i...j])
  pos = POS_MAP[s] || s
  #p pos

  i = body.index('Definition:', j) or return
  i = body.index('<td', i) or return
  j = body.index('</td', i) or return
  defn = strip_html(body[i...j])
  #p defn

  i = body.index('Synonyms:', j) or return
  i = body.index('<span', i) or return
  j = body.index('</span', j) or return
  synonyms = strip_html(body[i...j]).gsub(/\s+,/, ',').gsub(' *', '')

  "\002#{word}\002, #{pos}: #{defn}. syn: #{synonyms}"
end

m = match_args /(\w+)/, '<word>'
word = m[1]

body = http_get("http://thesaurus.com/browse/#", word)
if body && (res = parse_html(body, word))
  reply res
else
  reply "error parsing html for #{word}"
end
