require 'rubybot2/thread_janitor'
require 'rubybot2/web'
require 'open-uri'

# Grabs titles from web pages with non-useful URLs and displays them in
# the originating channel. Just youtube for now.
class TitleGrabber
    include Web

    def initialize(client)
        @client = client
        @channels = []
        @janitor = ThreadJanitor.new
    end

    def m_PRIVMSG(msg, replier)
        if msg.text =~ %r!((?:http://)?(?:\w+\.)?youtube\.com/watch[^ \t>)]+)!
            url = $1
            @janitor.register(Thread.new { fetch_title(url, replier) })
        end
    end

    def fetch_title(url, replier)
        body = open(url).read
        i = body.index('<title') or return
        j = body.index('</title', i) or return
        replier.reply("Title: #{strip_html(body[i...j])}")
    rescue Exception => e
        @client.logger.warn("!!! exception fetching #{url}: #{e.inspect}: #{e.message} #{e.backtrace.join("\n")}")
    end
end
