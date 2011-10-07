#!/usr/bin/env ruby

SYNTAX = 'Usage: !thesaurus <word>'

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
  p word

  i = body.index('Part of Speech:', j) or return
  i = body.index('<td', i) or return
  j = body.index('</td', i) or return
  s = strip_html(body[i...j])
  pos = POS_MAP[s] || s
  p pos

  i = body.index('Definition:', j) or return
  i = body.index('<td', i) or return
  j = body.index('</td', i) or return
  defn = strip_html(body[i...j])
  p defn

  i = body.index('Synonyms:', j) or return
  i = body.index('<span', i) or return
  j = body.index('</span', j) or return
  synonyms = strip_html(body[i...j]).gsub(/\s+,/, ',')

  "\002#{word}\002, #{pos}: #{defn}. syn: #{synonyms}"
end

def handle_command(nick, dest, args)
  args = args.split.first
  return "P\t#{SYNTAX}" if !args || args.length == 0

  body = open("http://thesaurus.com/browse/#{CGI.escape(args)}").read
  if body && (res = parse_html(body, args))
    "P\t#{res}"
  else
    "P\terror parsing html for #{args}"
  end
rescue OpenURI::HTTPError => e
  "P\terror looking up synonyms for #{args}: #{e.message}"
end

load 'boilerplate.rb'
