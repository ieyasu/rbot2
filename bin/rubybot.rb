#!/usr/bin/env ruby

require 'rubygems'

#trap('HUP') { $client.reload_plugins }
trap('TERM') { forcefully_quit('SIGTERM') }
trap('INT')  { forcefully_quit('SIGINT') } # ^c

def forcefully_quit(msg)
    $quitting = true
    $client.quit(msg) rescue nil
    exit!(0)
end

load 'config.rb'
require 'rubybot2/rbot2'

Thread.abort_on_exception = true

loop do
    begin
        $client = Rbot2.new
        $client.event_loop
        exit
    rescue
        sleep 17
    end
end
