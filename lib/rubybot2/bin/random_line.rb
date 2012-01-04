#!/usr/bin/env ruby

FILE_MAP = {
  'gq' => 'galenquotes',
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
  'tentaclerape' => 'na',
  'love' => 'na',
  'deepdick' => 'na'
}

def handle_command(nick, dest, args)
  # figure out which !command this is
  command = File.basename($0)

  return "P\tNo file mapping for #{command}!" unless FILE_MAP[command]

  # select random line from file
  random_line = nil
  IO.readlines('db/' + FILE_MAP[command]).each_with_index do |line, i|
    next if line.length < 3
    random_line = line if rand(i + 1) < 1
  end
  random_line = random_line.chop

  if FLAGS[command] && FLAGS[command].index('n')
    random_line = random_line.gsub('$args', args).gsub('$source', nick)
  end

  # print reply
  if FLAGS[command] && FLAGS[command].index('a')
    "P\t\001ACTION #{random_line}\001"
  else
    "P\t#{random_line}"
  end
end

load 'boilerplate.rb'
