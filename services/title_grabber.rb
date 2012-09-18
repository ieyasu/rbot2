#!/usr/bin/env ruby
# Grabs titles from web pages with non-useful URLs and displays them in
# the originating channel. Just youtube for now.

require 'rubybot2/plugin'
require 'rubybot2/thread_janitor'
require 'rubybot2/web'
include Web

GRAB_URLS = [%r!((?:https?://)?(?:\w+\.)?youtube\.com/watch[^ \t>)]+)!,
             %r!((?:https?://)?youtu.be/[\w\d]+)!i,
             %r!((?:https?://)?(?:i\.)?imgur\.com(?:/[\w\d]+)+)!i,
             %r!((?:https?://)?vimeo\.com/\d+)!]

def fetch_title(url, replier)
  body = http_get(url)
  i = body.index('<title') or return
  j = body.index('</title', i) or return
  replier.reply("Title: #{strip_html(body[i...j])}")
end

# ---

register IRC::CMD_PRIVMSG

$janitor = ThreadJanitor.new

message_loop do |msg, replier|
  if GRAB_URLS.any? {|url| msg.text =~ url}
    u = $1
    $janitor.register(Thread.new { fetch_title(u, replier) })
  end
end
