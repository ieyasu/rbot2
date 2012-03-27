#!/usr/bin/env ruby

require 'rubybot2/plugin'
require 'rubybot2/db'

CHECK_DELAY = 9

def check_jobs
  cutoff = Time.now.to_i + CHECK_DELAY / 2
  cron = DB[:cron].filter('at < ?', cutoff)
  rows = cron.all
  if rows.length > 0
    cron.delete
    rows.each do |row|
      to = IRC.channel_name?(row[:chan]) ? row[:chan] : row[:nick]
      $sender.privmsg(to, row[:message])
    end
  end
rescue Exception => e
  report_exception e
end

Thread.new do
  loop do
    sleep(CHECK_DELAY)
    check_jobs
  end
end

$sender = IRC::MessageSender.new STDOUT
register
message_loop { |msg, replier| }
