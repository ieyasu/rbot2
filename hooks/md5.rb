#!/usr/bin/env ruby

require 'digest/md5'
include Digest

def handle_command(nick, dest, args)
  "P\tMD5 of '#{args}' == #{MD5.new(args).hexdigest}"
end

load 'boilerplate.rb'
