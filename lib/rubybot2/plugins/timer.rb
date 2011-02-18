require 'rubybot2/db'
require 'rubybot2/replier'

# A sort of cron/at for the bot.  See that at and in commands in
# commands/in_at.rb
class Timer
    def initialize(client)
        @client = client
        @t = Thread.new do
            loop do
                sleep(CHECK_DELAY)
                check_jobs
            end
        end
    end

    private

    CHECK_DELAY = 17

    def check_jobs
        DB.lock do |dbh|
            cutoff = Time.now.to_i + CHECK_DELAY / 2
            rows = dbh.get("SELECT * FROM cron WHERE at < ?;", cutoff)
            if rows
                dbh.exec("DELETE FROM cron WHERE at < ?;", cutoff)
                IRC::Replier.lock do
                    rows.each {|row| deliver_message(*row) }
                end
            end
        end
    rescue Exception => e
        @client.logger.error("!!! #{e.inspect}: #{e.message} #{e.backtrace.join("\n")}")
    end

    def deliver_message(at, nick, dest, msg)
        to = IRC.channel_name?(dest) ? dest : nick
        @client.privmsg(to, msg)
    end
end
