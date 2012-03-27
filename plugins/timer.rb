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
    cutoff = Time.now.to_i + CHECK_DELAY / 2
    cron = DB[:cron].filter('at < ?', cutoff)
    rows = cron.all
    if rows.length > 0
      cron.delete
      IRC::Replier.lock do
        rows.each do |row|
          to = IRC.channel_name?(row[:chan]) ? row[:chan] : row[:nick]
          @client.privmsg(to, row[:message])
        end
      end
    end
  rescue Exception => e
    @client.logger.error("!!! #{e.inspect}: #{e.message} #{e.backtrace.join("\n")}")
  end
end
