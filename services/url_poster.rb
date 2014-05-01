#!/usr/bin/env ruby
# Posts URLs to a subreddit of your choice.

require 'rubybot2/plugin'
require 'rubybot2/thread_janitor'
require 'rubybot2/web'
include Web
require 'snoo'

URL_REGEX = [%r!^((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?$!]

if $rbconfig['reddit_user'] && $rbconfig['reddit_password'] && $rbconfig['reddit_sub'] then
  message_loop do |msg, replier|
    if URL_REGEX =~ msg.text
      url = $&
      r = Snoo::Client.new
      r.log_in $rbconfig['reddit_user'], $rbconfig['reddit_password']
      r.submit msg.text, $rbconfig['reddit_sub'], { :url => url}
    end
  end
end