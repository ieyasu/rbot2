require 'rubybot2/irc'
require 'rubybot2/simple_account'
require 'thread'

class IRC::TooManyLines < Exception; end

# Given an original request message and an irc client, allows client code
# high level access for responding to the request in different ways.
# There are a maximum number of allowed lines (IRC messages), different
# counts for public and private messages.
class IRC::Replier
    SOFT_PUBLIC_LIMIT = 4
    SOFT_PRIVATE_LIMIT = 12

    attr_accessor :defdest

    # Initializes the Replier from the given IRC client and request message.
    # Determines the default destination for a reply: if a message was sent
    # to a channel, then the reply will go to that channel by default; if
    # a message was sent to the bot, the reply will go to the sender directly.
    def initialize(client, msg)
        @client = client
        @msg = msg
        @public_lines = 0
        @private_lines = 0
        @defdest = msg.reply_to if msg.respond_to?(:reply_to)
        @@write_lock ||= Mutex.new
    end

    # Sends a PRIVMSG to the default destination with the given text.
    def reply(text)
        increment
        @@write_lock.synchronize do
            @client.privmsg(@defdest, text)
        end
    end

    # Send a PRIVMSG to the request message's nick with the given text.
    def priv_reply(text)
        increment_private
        @@write_lock.synchronize do
            @client.privmsg(@msg.nick, text)
        end
    end

    # Sends a /me action to the default destination with the given text.
    def action(text)
        increment
        @@write_lock.synchronize do
            @client.action(@defdest, text)
        end
    end

    # Sends the given raw irc message to the server.
    def raw(msg)
        increment
        @@write_lock.synchronize do
            begin
              @client.send_msg(msg)
            rescue ArgumentError => e
              @client.privmsg(@defdest, e.message)
            end
        end
    end

    # Holds the write lock on this replier for the duration of the given block.
    def self.lock(&block)
        @@write_lock = Mutex.new unless defined?(@@write_lock)
        @@write_lock.synchronize do
            block.call
        end
    end

    private

    def increment
        if IRC.channel_name?(@defdest)
            increment_public
        else
            increment_private
        end
    end

    def increment_public
        @public_lines += 1
        if @public_lines > SOFT_PUBLIC_LIMIT
            raise TooManyLines if @public_lines > SOFT_PUBLIC_LIMIT * 2
            sleep 0.1
        end
    end

    def increment_private
        @private_lines += 1
        if @private_lines > SOFT_PRIVATE_LIMIT
            raise TooManyLines if @private_lines > SOFT_PRIVATE_LIMIT * 2
            sleep 0.1
        end
    end
end
