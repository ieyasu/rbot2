#!/usr/bin/env ruby
# Posts URLs to a subreddit of your choice.

require 'rubybot2/plugin'
require 'rubybot2/thread_janitor'
require 'rubybot2/web'
include Web
require 'snoo'

$url_regex = Regexp.new(File.read('lib/rubybot2/url-regex').strip, Regexp::IGNORECASE)

def fetch_title(url)
  begin
    body = http_get(url)
    i = body.index('<title') or return
    j = body.index('</title', i) or return
    strip_html(body[i...j])
  rescue
    "Unknown title"
  end
end

register IRC::CMD_PRIVMSG

$janitor = ThreadJanitor.new

message_loop do |msg, replier|
  if $url_regex =~ msg.text
    if $rbconfig['reddit_users'] && $rbconfig['reddit_password'] && $rbconfig['reddit_sub'] then
      url = $&
      r = Snoo::Client.new
      r.log_in $rbconfig['reddit_users'].sample, $rbconfig['reddit_password']
      r.submit fetch_title(url), $rbconfig['reddit_sub'], { :url => url}
    end
  end
end