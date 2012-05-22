require 'shellwords'

if $args.length > 0
  s = `ping -c 1 #{Shellwords.shellescape $args} | grep "bytes from"`
  reply "ping: #{s}"
else
  reply "pong: #{$msg.nick} #{$msg.dest}"
end
