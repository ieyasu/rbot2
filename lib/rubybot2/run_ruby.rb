#!/usr/bin/env ruby
# Runs hooks written in Ruby
# Usage: $0 hooks/HOOK.rb COMMAND ARGS IRC_MESSAGE

require 'rubygems'

load 'config.rb'

require 'rubybot2/db'
require 'rubybot2/irc'
require 'rubybot2/web'
require 'rubybot2/replier'

include Web

def reply(text)
  $rep.reply text
end

def priv_reply(text)
  $rep.priv_reply text
end

def action(text)
  $rep.action text
end

def raw(msg)
  $rep.raw msg
end

def exit_reply(msg)
  $rep.reply msg
  exit 0
end

def match_args(pat, usage = nil)
  if (r = pat.match($args))
    r
  else
    usage = yield if block_given?
    exit_reply("Usage: #{$rbconfig['cmd_prefix']}#{$command} #{usage}")
  end
end

def each_line(file)
  File.open(file) do |fin|
    fin.each_line {|line| yield line}
  end
end

def r(ary)
  ary[rand(ary.size)]
end

# ---

$command = ARGV[1]
$args = ARGV[2]
$msg = IRC.parse_message(ARGV[3])
$rep = Replier.new($msg)

# Now ready to run hook
load ARGV[0]
