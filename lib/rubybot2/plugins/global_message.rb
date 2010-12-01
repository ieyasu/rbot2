require 'rubybot2/last'
require 'rubybot2/nextlib'

class GlobalMessage
    def initialize(client)
        @client = client
        @channels = []
    end

    # Request joined channel list as soon as client is accepted
    def m_001(msg, replier)
        @client.join($rbconfig['join-channels'])
        @client.send_msg("WHOIS #{$rbconfig['nick']}")
    end

    # Parse joined channel list
    def m_319(msg, replier)
        add_channels(msg.text)
    end

    # After we're done reading in list of joined channels, become oper
    # if applicable
    def m_318(msg, replier)
        unless @channels.empty?
            oper = $rbconfig['oper-name']
            return unless /.+/ =~ oper
            @client.send_msg("OPER #{oper} #{$rbconfig['oper-passwd']}")
	    mode = $rbconfig['oper-mode']
	    return unless mode =~ /^[a-zA-Z]+$/
            @client.send_msg("MODE #{$rbconfig['nick']} +#{mode}")
        end
    end

    def m_JOIN(msg, replier)
        if msg.nick == @client.nickname
            add_channels(msg.text)
            puts "Channels now: #{@channels.join(' ')}"
        end
    end

    # Record last statement said by nick and check if there are
    # messages for them
    def m_PRIVMSG(msg, replier)
        return unless msg.sent_to_channel?

        # update last statement
        unless $rbconfig['no-monitor-channels'].include?(msg.dest)
            Last.update(msg.nick, msg.dest, msg.text)
        end

        # check for nexts
        NextLib.read(msg.nick, replier)
    end

    private

    def add_channels(channel_list)
        @channels |= channel_list.split.map {|c| c[0,1] == '@' ? c[1..-1] : c }
    end
end
