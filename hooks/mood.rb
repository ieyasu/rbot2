#!/usr/bin/env ruby

MOODS = ['irritated',
         'sad',
         'depressed',
         'happy',
         'gassy',
         'hungry',
         'boisterous',
         'sexy',
         'confused',
         'flammable',
         'angry',
         'violent',
         'gay',
         'fabulous',
         'funky',
         'stupid',
         'a whole hell of a lot smarter than you right now',
         'ugly',
         'fat and sassy',
         'horny', 'horny', 'horny','horny','horny']

def handle_command(nick, dest, args)
  mood = MOODS[rand(MOODS.size)]
  "P\t\001ACTION is feeling #{mood} \001"
end

load 'boilerplate.rb'
