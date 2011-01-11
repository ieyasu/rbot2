require 'rubybot2/irc'
require 'rubybot2/web'
require 'rubybot2/simple_account'
load 'config.rb'

include Web

def reply(text)
  begin
    i = (text.length > 420) ? text.rindex(' ', 420) : text.length
	r = text[0,i]
    text = text[i + 1..-1]
    puts "PRIVMSG #{$___dest__} :#{r}"
  end while text && text.length > 1
end

begin
  $___dest__ = ($rbconfig['private-progs'].member?(File.basename($0)) ||
                !IRC.channel_name?(ARGV[1])) ? ARGV[0] : ARGV[1]
  msg = handle_command(ARGV[0], ARGV[1], ARGV[2]) # nick, dest, args
  if msg
    msg = msg.split(/\n+/) if msg.is_a?(String)
    msg.each do |line|
      case line
      when /^P\t\S+/
        reply(line[2..-1].strip)
      when /^R\t/
        puts line[2..-1]
      else
        STDERR.puts "'#{line.inspect}' is an unrecognized format"
      end
    end
  end
rescue Exception => e
  bt = e.backtrace
  bt = bt[0..2] + bt[-5..-1] if bt.length > 6
  reply("Exception: #{e.message}:: #{bt.join(' ;; ')}")
end
