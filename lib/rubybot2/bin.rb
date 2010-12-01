require 'rubybot2/irc'
require 'rubybot2/db'
require 'rubybot2/web'
require 'rubybot2/simple_account'
load 'config.rb'

# The parent class for all ruby language 'binary' external process commands.
# For your command, subclass Bin and name the file after the child class's
# name, replacing capital letters in the middle of the command with
# an underscore and that letter lower-cased.
class Bin
    include Web

    def initialize
        @defdest = ($rbconfig['private-progs'].member?(File.basename($0)) ||
                        !IRC.channel_name?(ARGV[1])) ? ARGV[0] : ARGV[1]
        @nick, @dest, @args = ARGV[0..2]
    end

    private

    # Returns the zip location for the account the given nick belongs to
    # or the default if there is no such account.
    def zip_by_nick(nick)
        DB.lock do |dbh|
            az = dbh.cell("SELECT accounts.zip FROM accounts, nick_accounts
                           WHERE nick_accounts.nick = ?
                           AND nick_accounts.account = accounts.name;", nick)
            unless az && az.to_i > 0
                az = $rbconfig['default-zip'] || 80523
            end
            az.to_s
        end
    end

    # Outputs a PRIVMSG reply to the default destination.
    def reply(text)
        puts "PRIVMSG #{@defdest} :#{text}"
    end

    # Outputs a raw IRC message.
    def raw(text)
        puts text
    end
end

BEGIN {
    klass = File.basename($0).capitalize.gsub(/_[a-z]/) { |m| m[1..1].upcase }
    bin = eval(klass).new
    bin.run
}
