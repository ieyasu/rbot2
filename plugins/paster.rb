#!/usr/bin/env ruby
# Reads from a FIFO /tmp/paste and spits the contents out on an IRC channel.
# Originally went with a web page that wrote to the FIFO, but this is not
# included with the bot.  You are on your own if you want to use this.

require 'rubybot2/plugin'
require 'socket'

PASTE_SOCKET = '/tmp/paste'

def handle_paste
  sock = $paste_sock.accept
  if (dest = sock.gets)
    dest = dest.chop
    sock.each_line do |line|
      line = line.strip
      $sender.privmsg(dest, line) if line.length > 0
    end
  end
rescue Exception => e
  report_exception e
ensure
  sock.close
end

File.unlink(PASTE_SOCKET) if File.exist?(PASTE_SOCKET)
$paste_sock = UNIXServer.open(PASTE_SOCKET)
File.chmod(0777, PASTE_SOCKET)

Thread.new do
  loop { handle_paste }
end

$sender = IRC::MessageSender.new STDOUT
register
message_loop { |msg, replier| }
