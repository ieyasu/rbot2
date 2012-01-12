#!/usr/bin/env ruby

require 'md5'

def handle_command(nick, dest, args)
  "P\tMD5 of '#{args}' == #{MD5.new(args).hexdigest}"
end

load 'boilerplate.rb'
