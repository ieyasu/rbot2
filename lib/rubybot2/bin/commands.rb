#!/usr/bin/env ruby

INTERNAL = ["accounts", "addnick", "at", "deletelastnext", "delnick", "forget",
            "help", "in", "listnexts", "login", "logout", "mremember", "next",
            "nicks", "pastnexts", "raw", "read", "register", "remember", "seen",
            "setemail", "setpass", "setzip", "unregister", "whatis"]

def handle_command(nick, dest, args)
  commands = (INTERNAL + (Dir.entries('bin') - ['.', '..'])).sort.join(', ')
  "P\t#{commands}"
end

load 'boilerplate.rb'
