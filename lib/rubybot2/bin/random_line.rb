#!/usr/bin/env ruby

HOOK_TO_FILE = {
  'gq' => 'galenquotes',
  'maruth' => 'maruth.txt',
  'dec' => 'dec.txt',
  'hst' => 'hst.txt',
  'bob' => 'bob.txt',
  '8ball' => '8ball.txt',
  'oblique' => 'oblique.txt',
  'truism' => 'truisms.txt',
  'bitchslap' => 'shots',
  'boot' => 'shots',
  'flog' => 'shots',
  'hit' => 'shots',
  'kick' => 'shots',
  'kill' => 'shots',
  'punch' => 'shots',
  'shoot' => 'shots',
  'slap' => 'shots',
  'smack' => 'shots',
  'smite' => 'shots',
  'spank' => 'shots',
  'stab' => 'shots',
  'tentaclerape' => 'shots',
  'love' => 'loves',
  'deepdick' => 'loves',
  'iching' => 'iching',
  'troy' => 'troy_mcclure.txt',
  'mcclure' => 'troy_mcclure.txt',
  'tracy' => 'tracy_morgan.txt'
}

# a - action instead of privmsg
# n - do shot/love-style name replacement
FLAGS = {
  'bitchslap' => 'na',
  'boot' => 'na',
  'flog' => 'na',
  'hit' => 'na',
  'kick' => 'na',
  'kill' => 'na',
  'punch' => 'na',
  'shoot' => 'na',
  'slap' => 'na',
  'smack' => 'na',
  'smite' => 'na',
  'spank' => 'na',
  'stab' => 'na',
  'tentaclerape' => 'na',
  'love' => 'na',
  'deepdick' => 'na'
}

# Does a fish-yates shuffle on the lines from infile, writing to outfile
def shuffle_file(infile, outfile)
  lines = File.open(infile) {|fin| fin.readlines}
  j = lines.length - 1
  begin
    k = rand(lines.length)
    l = lines[k]
    lines[k] = lines[j]
    lines[j] = l
    j -= 1
  end while j > 0
  File.open(outfile, 'w') {|fout| fout.puts(lines)}
end

def random_line(file)
  random_file = "#{file}-rand"
  unless File.exist?(random_file)
    shuffle_file(file, random_file)
  end

  # grab and delete last line of file
  File.open(random_file, 'r+') do |fin|
    text = fin.read
    i = text.rindex("\n", text.length - 2)
    j = i ? i + 1 : 0
    last_line = text[j..-1].rstrip
    if i
      fin.truncate(text[0..i].bytesize)
    else
      File.delete(random_file)
    end
    last_line
  end
end

def handle_command(nick, dest, args)
  # figure out which !command this is
  command = File.basename($0)
  file = HOOK_TO_FILE[command]
  return "P\tNo file mapping for #{command}!" unless file
  rl = random_line("db/#{file}")

  if FLAGS[command] && FLAGS[command].index('n')
    rl = rl.gsub('$args', args).gsub('$source', nick)
  end

  if FLAGS[command] && FLAGS[command].index('a')
    "P\t\001ACTION #{rl}\001"
  else
    "P\t#{rl}"
  end
end

load 'boilerplate.rb'
