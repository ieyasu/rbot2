require 'rubybot2/irc'

class IRC::TooManyLines < Exception; end

STDOUT.sync = true # don't need to call flush

# Given an original request message, provides high level interface for
# sending IRC messages of various kinds, public or private.  There are
# a maximum number of allowed lines (IRC messages), different counts
# for public and private messages.
class Replier
  SOFT_PUBLIC_LIMIT = 4
  SOFT_PRIVATE_LIMIT = 12

  attr_accessor :default_dest

  # Initializes the Replier from the given IRC client and request message.
  # Determines the default destination for a reply: if a message was sent
  # to a channel, then the reply will go to that channel by default; if
  # a message was sent to the bot, the reply will go to the sender directly.
  def initialize(msg)
    @sender = IRC::MessageSender.new(STDOUT)
    @nick = msg.respond_to?(:nick) ? msg.nick : 'nick'
    @public_lines = 0
    @private_lines = 0
    @default_dest = msg.reply_to if msg.respond_to?(:reply_to)
  end

  # Sends a PRIVMSG to the default destination with the given text.
  def reply(text)
    increment
    @sender.privmsg(@default_dest, text)
  end

  # Send a PRIVMSG to the request message's nick with the given text.
  def priv_reply(text)
    increment_private
    @sender.privmsg(@nick, text)
  end

  # Sends a /me action to the default destination with the given text.
  def action(text)
    increment
    @sender.action(@default_dest, text)
  end

  # Sends the given raw irc message to the server.
  def raw(msg)
    increment
    begin
      @sender.send_msg(msg)
    rescue ArgumentError => e
      @sender.privmsg(@default_dest, e.message)
    end
  end

  private

  def increment
    if IRC.channel_name?(@default_dest)
      increment_public
    else
      increment_private
    end
  end

  def increment_public
    @public_lines += 1
    if @public_lines > SOFT_PUBLIC_LIMIT
      raise IRC::TooManyLines if @public_lines > SOFT_PUBLIC_LIMIT * 2
      sleep 0.1
    end
  end

  def increment_private
    @private_lines += 1
    if @private_lines > SOFT_PRIVATE_LIMIT
      raise IRC::TooManyLines if @private_lines > SOFT_PRIVATE_LIMIT * 2
      sleep 0.1
    end
  end
end
