require 'rubybot2/irc'
require 'rubybot2/replier'
require 'rubybot2/logger'

def file_to_class(filename)
    File.basename(filename) =~ /(\w+)\.rb$/
    s = $1.gsub(/(?:\A|_|-)[a-z]/) { |m| m[-1,1].upcase }
    Module.const_get(s.to_sym)
end

class Rbot2 < IRC::Client
    IRC_ACTIVITY_TIMEOUT = 10 * 60
    HEARTBEAT_INTERVAL   = 3 * 60 * 60

    attr_reader :logger

    def initialize
        @logger = RbotLogger.open_log
        load_plugins
        super($rbconfig['host'], $rbconfig['port'])
        init_irc
    end

    def load_plugins
        ary = Dir.glob('plugins/*.rb').sort
        @plugins = ary.map do |pf|
            @logger.info "Loading plugin #{pf}"
            load pf
            file_to_class(pf).new(self)
        end
    end

    def init_irc
        register($rbconfig['nick'], $rbconfig['ircname'])
        client, logger = self, @logger
        @sock.instance_eval { @client, @logger = client, logger }
        def @sock.gets
            text = super
	    until text
	        sleep 0.5
	        text = super
	    end
            @logger.info ">>> #{text.strip}"
            text
        rescue IOError, Errno::EBADF, Errno::EPIPE # attempt reconnect
            @client.reconnect
            @client.sock.gets
        end
        def @sock.write(text)
            super(text)
            @logger.info "<<< #{text.strip}"
            # echo message from command or hook back to all hooks
            msg = IRC.parse_message(":#{@client.prefix} #{text}")
            @client.message_received(msg)
        rescue IOError, Errno::EBADF, Errno::EPIPE # attempt reconnect
            @client.reconnect
            @client.sock.write(text)
        rescue ArgumentError => e
            @logger.exception(e) # bad irc message, probably
        end
    end

    def reload_plugins
        @plugins.clear
        load_plugins
    end

    def event_loop
        @logger.info '*** entering event loop'
        last_irc_message_at = Time.now

        t = Thread.new do
            loop do
                sleep(IRC_ACTIVITY_TIMEOUT)
                elapsed = Time.now - last_irc_message_at
                if elapsed >= IRC_ACTIVITY_TIMEOUT
                    @sock.close rescue nil # trigger reconnect
                    last_irc_message_at = Time.now # slow down worst-case
                elsif elapsed >= HEARTBEAT_INTERVAL
                    @logger.info '*** ---MARK---'
                end
            end
        end

        begin
            if (msg = read_message)
                last_irc_message_at = Time.now
                message_received(msg)
            end
        rescue IRC::MessageParseError => e
            @logger.exception(e)
        rescue SystemExit
            break # quit called
        end until @sock.closed?

        @logger.info '*** quitting'
        @logger.close
    rescue Exception => e
        msg = @logger.exception(e)
        quit(msg) unless @sock.closed?
    end

    def message_received(msg)
        echo = (msg.nick == @nickname)
        msgsym = "m_#{msg.command}".to_sym
        @plugins.each do |plugin|
            next if echo && !(plugin.respond_to?(:receive_echoes?) &&
                                  plugin.receive_echoes?)
            begin
                r = IRC::Replier.new(self, msg)
                plugin.send(msgsym, msg, r) if plugin.respond_to?(msgsym)
            rescue IRC::TooManyLines
                @logger.warn "!!! Plugin #{plugin.class} wrote too much"
            rescue => e
                @logger.exception e
            end
        end
    end

    def reconnect
        unless defined?($quitting) && $quitting
            @logger.error "!!! reconnecting to IRC server"
            super
            init_irc
        end
    end
end
