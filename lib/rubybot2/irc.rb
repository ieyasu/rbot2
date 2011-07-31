require 'socket'

# Implements IRC protocol client capabilities. We try to follow the
# specification in {RFC 2812}[http://ietf.org/rfc/rfc2812.txt] while remaining
# flexible and pragmatic to work with actual server implementations. While the
# methods and classes here have been (the author hopes) reasonably well
# documented, they are not a protocol specification and you are encouraged to
# read the IRC RFCs (2810[http://ietf.org/rfc/rfc2810.txt],
# 2811[http://ietf.org/rfc/rfc2811.txt], 2812[http://ietf.org/rfc/rfc2812.txt],
# 2813[http://ietf.org/rfc/rfc2813.txt] and
# 1459[http://ietf.org/rfc/rfc1459.txt]).
module IRC
    # The typical port on which an IRC server listens for incoming connections.
    DEFAULT_PORT = 6667
    # The maximum number of space-separated parameters to an IRC command.
    MAX_MESSAGE_PARAMS = 15
    # The maximum length of an IRC message, including the nick!user@host prefix.
    # Clients do not send the prefix but need to take its length into account
    # since the server will prepend it to the client's messages before sending
    # it on to the other clients.
    MAX_MESSAGE_LENGTH = 512
    # Maximum length of a channel name.
    MAX_CHANNEL_LENGTH = 50

    nick = "[A-}][\\-0-9A-}]*"

    # Matches valid nicknames. Does not bother with length since servers do
    # not limit nicks to 9 characters as in RFC 2812.
    NICK_REGEX = Regexp.new(nick)

    hostname = "[^ .]+(?:\\.[^ .]+)*"
    prefix = "(?::(?:#{nick}(?:(?:![^\000\r\n @]+)?@#{hostname})?|#{hostname}) )?"
    command = "(?:\\d{3}|[A-Z]+)"
    param = "[\001-\t\v\f\016-\037!-9;-\377][^ \000\r\n]*"
    parameters = "(?:\s+#{param})*(?:\s+:[^\000\r\n]*)?"

    # Matches valid IRC messages. The pattern is not particularly thorough
    # and is more geared to letting reasonable things through rather than
    # a fully rfc-compliant matcher (which is decidedly nasty to do in a
    # single regular expression).
    MESSAGE_REGEX = Regexp.new("^" + prefix + command + parameters + "$")

    # Matches valid channel names, not counting the length. Allows minimal
    # channel names _#_, _+_, _&_ disallowed by RFC 2812 but seen in practice.
    #
    # From RFC 2812:
    #   channel    =  ( "#" / "+" / ( "!" channelid ) / "&" ) chanstring
    #                 [ ":" chanstring ]
    #   chanstring =  %x01-07 / %x08-09 / %x0B-0C / %x0E-1F / %x21-2B
    #   chanstring =/ %x2D-39 / %x3B-FF
    #   channelid  = 5( %x41-5A / digit )   ; 5( A-Z / 0-9 )
    CHAN_REGEX = /^(?:#|\+|&|(?:![0-9A-Z]{5}))(?:[^\x07 :,][^\x07 ,]*)?$/

    USER_MODE_REGEX = /^(?:[+-][a-z]*)*$/i

    CHANNEL_MODE_REGEX = /^(?:[+-][a-z]*(?: \S+)?(?: [+-][a-z]*(?: \S+)?)*)?$/

    # Returns true if the destination is a valid IRC channel name.
    def IRC.channel_name?(dest)
        dest && dest.length < MAX_CHANNEL_LENGTH && (not dest !~ CHAN_REGEX)
    end

    # Returns true if _nick_ is a valid IRC nickname.
    def IRC.nickname?(nick)
        nick =~ NICK_REGEX
    end

    # Returns true if _msg_ is a valid IRC message.
    def IRC.valid_message?(msg)
        msg.rstrip!
        msg.length <= MAX_MESSAGE_LENGTH and msg =~ MESSAGE_REGEX
    end

    # Class +Client+ provides an IRC client for user agents, services, and
    # bots. As soon as you create a new +Client+ object, a session is opened
    # to the IRC server. You should then call #register or #register_service
    # to tell the server who and what you are. Then you can set up an event
    # loop to wait for messages, calling #read_message to read and parse the
    # messages when they come in. Finally, there are many methods which send
    # various message types to the server.
    #
    # Typically, you will use the class like so:
    #
    #   client = Client.new('server')
    #   client.register('nick', 'real name', 'secret')
    #
    # Which connects to the server and tells it who you are. Then enter an
    # event loop to process the messages:
    #
    #   while select([client]) and (msg = client.read_message)
    #     case msg.command
    #     when IRC::CMD_PRIVMSG
    #       # display messasge...
    #     when IRC::CMD_TOPIC
    #       # make note of topic change...
    #     end
    #   end
    class Client
        attr_reader :sock, :server, :port, :nickname, :prefix

        # Opens a TCP connection to _server:port_.
        def initialize(server, port = DEFAULT_PORT)
            @server = server
            @port = port.to_i
            @port = DEFAULT_PORT if @port == 0
            @sock = TCPSocket.open(@server, @port)
            @prefix = 'nick!user@host' # dummy for now
        end

        # Tells the IRC server who you are. The _nickname_ parameter is the
        # name by which other clients display your messages; _realname_ is
        # a more elaborate name containing the name of the person behind
        # the user agent or (more commonly) a silly witticism. The _passwd_
        # is +nil+ by default and therefore will not be sent. The mode
        # parameter is an integer bitmask where setting bit 2 requests user
        # mode _w_ be set (the client receives wallops), and setting bit 3
        # requests mode sets user mode _i_ (marks client invisible).
        def register(nicknam, realname, passwd = nil, mode = 0)
            pass(passwd) if passwd
            nick(nicknam)
            user(nicknam, realname, mode)
        end

        # Tells the IRC server that this client is a service and some basic
        # information about the service. The _distribution_ parameter is a
        # wildcard pattern matching server name(s) that the service should
        # be visible to.
        def register_service(nicknam, realname, distribution, info, passwd = nil)
            pass(passwd) if passwd
            service(nicknam, distribution, info)
            user(nicknam, realname)
        end

        # Attempts to reconnect to the save server and port
        def reconnect
            @sock.close rescue nil
            sleep 1
            @sock = TCPSocket.open(@server, @port)
            sleep 1
        end

        # Reads the next message from the IRC socket and parses it. Returns
        # the parsed +IRC::Message+ or subclass or +nil+ if socket was
        # closed.
        #
        # The method looks for +IRC::RPL_WELCOME+ messages from which it
        # obtains the client's true prefix (nick!user@host), and
        # +IRC::CMD_PING+ messages which it responds to automatically
        # with a +IRC::CMD_PONG+.
        def read_message
            if (line = @sock.gets and msg = IRC.parse_message(line))
                case msg.command
                when IRC::RPL_WELCOME
                    i = msg.params[-1].rindex(' ') || -1
                    @prefix = msg.params[-1][i + 1..-1]
                when IRC::CMD_PING
                    pong(msg)
                when IRC::CMD_NICK
                    # check if our nick got changed by the server
                    @nickname = msg.params[0] if msg.nick == @nickname
                end
                msg
            end
        end

        # Send an action message (actually a PRIVMSG with "\001ACTION...\001"
        # set around the action text). The message is truncated if it
        def action(dests, text)
            msg = "PRIVMSG #{comma_join(dests)} :\001ACTION #{text}"
            msg = truncate(msg, 1)
            send_msg(msg << "\001")
        end

        # Joins the indicated channels. You can give a single channel as a
        # string or multiple channels in an array. Keys are optional. If you
        # specify a single key, pass it as a string, otherwise pass the keys
        # in an array.
        def join(channels, keys = nil)
            channels = comma_join(channels) if channels.is_a?(Array)
            keys = comma_join(keys) if keys.is_a?(Array)
            send_msg("JOIN #{channels} #{keys}".rstrip)
        end

        # Sends a user MODE message. If modes is +nil+ (the default), mode will
        # be queried and the result returned in a RPL_UMODEIS. Otherwise, the
        # nick's mode is requested to be set as specified. If nick is +nil+
        # (the default), the client's current nickname will be used.
        def user_mode(modes = nil, nicknam = nil)
            raise ArgumentError, 'bad user mode' unless modes =~ USER_MODE_REGEX
            raise ArgumentError, 'bad nickname' unless !nick || IRC.nickname?(nicknam)
            send_msg("MODE #{nicknam || @nickname} #{modes}")
        end

        # Sends a channel mode message.
        def channel_mode(channel, modes)
            raise ArgumentError, 'bad channel name' unless IRC.channel_name?(channel)
            raise ArgumentError, 'bad channel mode' unless modes =~ CHANNEL_MODE_REGEX
            send_msg("MODE #{channel} #{modes}")
        end

        # Changes the client's nickname.
        def nick(nicknam)
            raise 'invalid nick' unless IRC.nickname?(nicknam)
            @nickname = nicknam
            send_msg("NICK #{@nickname}")
        end

        # Sends a NOTICE to the given nick. Splits the text into multiple
        # NOTICEs if necessary.
        def notice(to_nick, text)
            split_send("NOTICE #{to_nick} :", text)
        end

        # Sends an OPER message with the given user and password.
        def oper(user, password)
            send_msg("OPER #{user} #{password}")
        end

        # Parts the given channel(s). If you want to part from a single channel
        # you should pass it in a string, otherwise send multiple channels in
        # an array.
        def part(channels)
            send_msg("PART #{comma_join(channels)}")
        end

        # Sends a PASS message. Unless you are doing something special, this
        # should not be called directly. Use #register or #register_service
        # instead.
        def pass(passwd)
            send_msg("PASS #{passwd}")
        end

        # Sends a PONG message in response to the given PING _msg_. You need
        # not normally call this to respond to PINGs because #read_message
        # takes care of it for you.
        def pong(msg)
            raise ArgumentError, 'message not a PING' if msg.command != 'PING'
            send_msg("PONG #{msg.params.join(' ')}")
        end

        # SENDS a PRIVMSG to the given nick or channel _dests_. If there is a
        # single destination, pass it as a string; otherwise pass an array of
        # destinations. If the text is too long, it will be split into
        # multiple PRIVMSGs.
        def privmsg(dests, text)
            split_send("PRIVMSG #{comma_join(dests)} :", text)
        end

        # Quits the IRC session, closing the socket in the process. You may
        # optionally include a reason to send with the quit.
        def quit(reason = 'bye')
            send_msg("QUIT :#{reason}")
            @sock.close
            exit
        end

        # Sends a SERVICE message to the server, registering this client as a
        # service. It is used in place of a NICK message. The _nickname_ is the
        # name used to refer to the service; _distribution_ is a pattern
        # (containing * and ? wildcards) used to specify which servers will
        # make use of this service; _info_ is an informative message about
        # what services this service provides.
        #
        # You do not normally need to call this directly; instead use
        # #register_service.
        def service(nicknam, distribution, info)
            @nickname = nicknam
            send_msg("SERVICE #{@nickname} * #{distribution} 0 0 :#{info}")
        end

        # Sends a TOPIC message to the given _channel_. If a _topic_ is given,
        # the topic will be set to that string. Otherwise, the channel's topic
        # is queried and will result in a RPL_TOPIC reply.
        def topic(channel, topic = nil)
            topic = ":#{topic}" if topic
            send_msg("TOPIC #{channel} #{topic}")
        end

        # Sends a USER message to the server. You do not normally need to call
        # this directly; instead use #register or #register_service.
        def user(username, realname, mode = 0)
            host = TCPSocket.gethostbyname(Socket.gethostname)[0]
            send_msg("USER #{username} #{mode} * :#{realname}")
        end

        # Sends a raw IRC message string _msg_ after truncating it to a size
        # that can be sent.
        def send_truncated(msg)
            send_msg(truncate(msg))
        end

        # Sends a raw IRC message string _msg_. All other methods that send
        # messages call this one with a formatted message string. First the
        # method calls +msg.strip+ and appends "\r\n" to _msg_, then validates
        # the result. The message is sent with #write. The munged message is
        # returned.
        def send_msg(msg)
            m = "#{msg.strip}\r\n"
            if m.length + PREFIX_MAX > MAX_MESSAGE_LENGTH
                raise "message '#{m.chop}' is too long to send"
            elsif m[0..-3] =~ MESSAGE_REGEX
                @sock.write(m)
            else
                raise ArgumentError, "invalid IRC message '#{m[0..-3]}'"
            end
            m
        end
    protected
        MIN_SPLIT = 32
        PREFIX_MAX = 32

        # Used to send multiple messages when the text is too long to send at
        # once. Splits _text_ into sufficiently small pieces to send with the
        # _prefix_ (taking into account the nick!user@host prefix that the
        # server will prepend). Tries to split _text_ on a space or tab if
        # it can.
        def split_send(prefix, text)
            pfxlen = PREFIX_MAX + prefix.length + @prefix.length
            raise ArgumentError, 'prefix too long' if pfxlen >= MAX_MESSAGE_LENGTH - MIN_SPLIT
            begin
                if pfxlen + text.length > MAX_MESSAGE_LENGTH
                    j = MAX_MESSAGE_LENGTH - pfxlen
                    i = text.rindex(/[ \t]/, j)
                    i = j if !i || (i < MIN_SPLIT && i < text.length - 1)
                    msg = text[0...i].rstrip
                    text = text[i..-1].lstrip
                else
                    msg = text
                    text = ''
                end
                send_msg(prefix + msg)
            end while text.length > 0
        end

        # Handles munging of string or array arguments to methods taking
        # one or many 'arguments' for that parameter such as JOIN or
        # PRIVMSG destinations.
        def comma_join(data)
            if data.is_a?(Array)
                data.join(',')
            else
                data || ''
            end
        end

        # Truncates the message to length
        def truncate(msg, extra = 0)
            max = MAX_MESSAGE_LENGTH - @prefix.length - 3 - extra
            msg = msg[0..max] if msg.length > max
            msg
        end
    end

    # Class MessageParseError is thrown by IRC.parse_message when the format
    # of the IRC message it is asked to parse does not match the RFC.
    class MessageParseError < Exception; end

    # A factory method which takes a raw IRC message, does some simple
    # parsing and returns a new +Message+ (or subclass) for it.
    def IRC.parse_message(line)
        str = line.chomp
        unless IRC.valid_message?(str)
            raise MessageParseError, "#{str.inspect} not an IRC message"
        end

        # prefix
        prefix = nil
        if str[0,1] == ':' # parse prefix
            prefix, str = str[1..-1].split(' ', 2)
        end

        # command, params
        params = str.scan(/:.+|[^ ]+/)
        command = params.shift

        klass = (command == CMD_PRIVMSG) ? PrivMessage : Message
        klass.new(line.chomp, prefix, command, params)
    end

    # The +Message+ class represents a general IRC message. It is subclassed
    # for particularly interesting message types such as PRIVMSG. These
    # should usually be created with IRC::parse_message.
    class Message
        attr_reader :prefix, :command, :params, :full_message

        # From RFC 2812:
        #   prefix = servername / ( nickname [ [ "!" user ] "@" host ] )
        PREFIX_PAT = /([^!@]+)(?:!([^@]+))?(?:@(.+))?/

        # The parameter _full_message_ is the complete IRC message string;
        # _prefix_ is the nick!user@host prefix if present, +nil+ otherwise;
        # _command_ is the message's command field; and _params_ is an array
        # of parameters to the message, <code>[]</code> if there are no
        # such parameters.
        #
        # You probably do not want to instantiate this directly; instead use
        # IRC::parse_message.
        def initialize(full_message, prefix, command, params)
            @full_message = full_message
            @prefix = prefix
            @command = command
            @params = params
        end

        # Returns the full, raw IRC message excluding the CRLF
        # end-of-line marker.
        def to_s
            @full_message
        end

        # Returns an array of the _nickname_, _user_, and _host_ fields of
        # the message's prefix using the PREFIX_PAT pattern or +nil+ if the
        # pattern does not match because the prefix is a server name.
        def split_prefix
            [$1, $2, $3] if @prefix =~ PREFIX_PAT
        end

        # Returns the _nickname_ portion of the message prefix or +nil+
        # if the prefix is not present or a server name.
        def nick
            @prefix =~ PREFIX_PAT and $1
        end

        # Returns the _user_ portion of the message prefix or +nil+
        # if the prefix is not present or a server name.
        def user
            @prefix =~ PREFIX_PAT and $2
        end

        # Returns the _host_ portion of the message prefix or +nil+
        # if the prefix is not present or a server name.
        def host
            @prefix =~ PREFIX_PAT and $3
        end

        # The final message parameter when it is preceded by a colon (':');
        # +nil+ otherwise. Typically this is a user-visible message.
        def text
            s = @params[-1]
            if s[0,1] == ':'
                s[1..-1]
            end
        end
    end

    # This class represents IRC messages with the _PRIVMSG_ command. These
    # should usually be created with IRC::parse_message.
    class PrivMessage < Message
        # The parameter _full_message_ is the complete IRC message string;
        # _prefix_ is the nick!user@host prefix if present, +nil+ otherwise;
        # _command_ is the message's command field; and _params_ is an array
        # of parameters to the message, <code>[]</code> if there are no
        # such parameters.
        #
        # You probably do not want to instantiate this directly; instead use
        # IRC::parse_message.
        def initialize(full_message, prefix, command, params)
            super(full_message, prefix, command, params)
        end

        # The channel or nickname that this message was sent to.
        def dest
            @params[0]
        end

        # Tests for presence of the /me-type action flag which IRC clients
        # typically display as
        #   * NICK ACTION
        def action?
            text[0,8] == "\001ACTION "
        end

        # Returns true if the message was sent to a channel.
        def sent_to_channel?
            IRC.channel_name?(dest)
        end

        # Returns the destination a reply message should be sent to.
        # If the message was sent to a nick, it was sent to this client
        # only, and therefore a reply should be sent to the sender only.
        # If the message was sent to a channel, the reply should be sent
        # to that channel as well.
        def reply_to
            sent_to_channel? ? dest : nick
        end
    end

    # message constants
    CMD_ADMIN    = 'ADMIN'
    CMD_AWAY     = 'AWAY'
    CMD_CONNECT  = 'CONNECT'
    CMD_ERROR    = 'ERROR'
    CMD_INFO     = 'INFO'
    CMD_INVITE   = 'INVITE'
    CMD_ISON     = 'ISON'
    CMD_JOIN     = 'JOIN'
    CMD_KICK     = 'KICK'
    CMD_KILL     = 'KILL'
    CMD_LINKS    = 'LINKS'
    CMD_LIST     = 'LIST'
    CMD_MODE     = 'MODE'
    CMD_NAMES    = 'NAMES'
    CMD_NICK     = 'NICK'
    CMD_NOTICE   = 'NOTICE'
    CMD_OPER     = 'OPER'
    CMD_OPERWALL = 'WALLOPS'
    CMD_PART     = 'PART'
    CMD_PASS     = 'PASS'
    CMD_PING     = 'PING'
    CMD_PONG     = 'PONG'
    CMD_PRIVMSG  = 'PRIVMSG'
    CMD_QUIT     = 'QUIT'
    CMD_REHASH   = 'REHASH'
    CMD_RESTART  = 'RESTART'
    CMD_SERVER   = 'SERVER'
    CMD_SQUIT    = 'SQUIT'
    CMD_STATS    = 'STATS'
    CMD_SUMMON   = 'SUMMON'
    CMD_TIME     = 'TIME'
    CMD_TOPIC    = 'TOPIC'
    CMD_TRACE    = 'TRACE'
    CMD_USERHOST = 'USERHOST'
    CMD_USERS    = 'USERS'
    CMD_USER     = 'USER'
    CMD_VERSION  = 'VERSION'
    CMD_WHOIS    = 'WHOIS'
    CMD_WHOWAS   = 'WHOWAS'
    CMD_WHO      = 'WHO'

    RPL_WELCOME           = '001'
    RPL_YOURHOST          = '002'
    RPL_CREATED           = '003'
    RPL_MYINFO            = '004'
    RPL_BOUNCE            = '005'

    RPL_TRACELINK         = '200'
    RPL_TRACECONNECTING   = '201'
    RPL_TRACEHANDSHAKE    = '202'
    RPL_TRACEUNKNOWN      = '203'
    RPL_TRACEOPERATOR     = '204'
    RPL_TRACEUSER         = '205'
    RPL_TRACESERVER       = '206'
    RPL_TRACESERVICE      = '207'
    RPL_TRACENEWTYPE      = '208'
    RPL_TRACECLASS        = '209'
    RPL_TRACERECONNECT    = '210'
    RPL_STATSLINKINFO     = '211'
    RPL_STATSCOMMANDS     = '212'
    RPL_STATSCLINE        = '213'
    RPL_STATSNLINE        = '214'
    RPL_STATSILINE        = '215'
    RPL_STATSKLINE        = '216'
    RPL_STATSQLINE        = '217'
    RPL_STATSYLINE        = '218'
    RPL_ENDOFSTATS        = '219'
    RPL_UMODEIS           = '221'
    RPL_SERVICEINFO       = '231'
    RPL_ENDOFSERVICES     = '232'
    RPL_SERVICE           = '233'
    RPL_SERVLIST          = '234'
    RPL_SERVLISTEND       = '235'
    RPL_STATSVLINE        = '240'
    RPL_STATSLLINE        = '241'
    RPL_STATSUPTIME       = '242'
    RPL_STATSOLINE        = '243'
    RPL_STATSHLINE        = '244'
    RPL_STATSSLINE        = '244'
    RPL_STATSPING         = '246'
    RPL_STATSBLINE        = '247'
    RPL_STATSDLINE        = '250'
    RPL_LUSERCLIENT       = '251'
    RPL_LUSEROP           = '252'
    RPL_LUSERUNKNOWN      = '253'
    RPL_LUSERCHANNELS     = '254'
    RPL_LUSERME           = '255'
    RPL_ADMINME           = '256'
    RPL_ADMINLOC1         = '257'
    RPL_ADMINLOC2         = '258'
    RPL_ADMINEMAIL        = '259'
    RPL_TRACELOG          = '261'
    RPL_TRACEEND          = '262'
    RPL_TRYAGAIN          = '263'

    RPL_NONE              = '300'
    RPL_AWAY              = '301'
    RPL_USERHOST          = '302'
    RPL_ISON              = '303'
    RPL_UNAWAY            = '305'
    RPL_NOWAWAY           = '306'
    RPL_WHOISUSER         = '311'
    RPL_WHOISSERVER       = '312'
    RPL_WHOISOPERATOR     = '313'
    RPL_WHOWASUSER        = '314'
    RPL_ENDOFWHO          = '315'
    RPL_WHOISCHANOP       = '316'
    RPL_WHOISIDLE         = '317'
    RPL_ENDOFWHOIS        = '318'
    RPL_WHOISCHANNELS     = '319'
    RPL_LISTSTART         = '321'
    RPL_LIST              = '322'
    RPL_LISTEND           = '323'
    RPL_CHANNELMODEIS     = '324'
    RPL_UNIQOPIS          = '325'
    RPL_NOTOPIC           = '331'
    RPL_TOPIC             = '332'
    RPL_INVITING          = '341'
    RPL_SUMMONING         = '342'
    RPL_INVITELIST        = '346'
    RPL_ENDOFINVITELIST   = '347'
    RPL_EXCEPTLIST        = '348'
    RPL_ENDOFEXCEPTLIST   = '349'
    RPL_VERSION           = '351'
    RPL_WHOREPLY          = '352'
    RPL_NAMREPLY          = '353'
    RPL_KILLDONE          = '361'
    RPL_CLOSING           = '362'
    RPL_CLOSEEND          = '363'
    RPL_LINKS             = '364'
    RPL_ENDOFLINKS        = '365'
    RPL_ENDOFNAMES        = '366'
    RPL_BANLIST           = '367'
    RPL_ENDOFBANLIST      = '368'
    RPL_ENDOFWHOWAS       = '369'
    RPL_INFO              = '371'
    RPL_MOTD              = '372'
    RPL_INFOSTART         = '373'
    RPL_ENDOFINFO         = '374'
    RPL_MOTDSTART         = '375'
    RPL_ENDOFMOTD         = '376'
    RPL_YOUREOPER         = '381'
    RPL_REHASHING         = '382'
    RPL_YOURESERVICE      = '383'
    RPL_MYPORTIS          = '384'
    RPL_TIME              = '391'
    RPL_USERSSTART        = '392'
    RPL_USERS             = '393'
    RPL_ENDOFUSERS        = '394'
    RPL_NOUSERS           = '395'

    ERR_NOSUCHNICK        = '401'
    ERR_NOSUCHSERVER      = '402'
    ERR_NOSUCHCHANNEL     = '403'
    ERR_CANNOTSENDTOCHAN  = '404'
    ERR_TOOMANYCHANNELS   = '405'
    ERR_WASNOSUCHNICK     = '406'
    ERR_TOOMANYTARGETS    = '407'
    ERR_NOSUCHSERVICE     = '408'
    ERR_NOORIGIN          = '409'
    ERR_NORECIPIENT       = '411'
    ERR_NOTEXTTOSEND      = '412'
    ERR_NOTOPLEVEL        = '413'
    ERR_WILDTOPLEVEL      = '414'
    ERR_BADMASK           = '415'
    ERR_UNKNOWNCOMMAND    = '421'
    ERR_NOMOTD            = '422'
    ERR_NOADMININFO       = '423'
    ERR_FILEERROR         = '424'
    ERR_NONICKNAMEGIVEN   = '431'
    ERR_ERRONEUSNICKNAME  = '432'
    ERR_NICKNAMEINUSE     = '433'
    ERR_NICKCOLLISION     = '436'
    ERR_UNAVAILRESOURCE   = '437'
    ERR_USERNOTINCHANNEL  = '441'
    ERR_NOTONCHANNEL      = '442'
    ERR_USERONCHANNEL     = '443'
    ERR_NOLOGIN           = '444'
    ERR_SUMMONDISABLED    = '445'
    ERR_USERSDISABLED     = '446'
    ERR_NOTREGISTERED     = '451'
    ERR_NEEDMOREPARAMS    = '461'
    ERR_ALREADYREGISTRED  = '462'
    ERR_NOPERMFORHOST     = '463'
    ERR_PASSWDMISMATCH    = '464'
    ERR_YOUREBANNEDCREEP  = '465'
    ERR_YOUWILLBEBANNED   = '466'
    ERR_KEYSET            = '467'
    ERR_CHANNELISFULL     = '471'
    ERR_UNKNOWNMODE       = '472'
    ERR_INVITEONLYCHAN    = '473'
    ERR_BANNEDFROMCHAN    = '474'
    ERR_BADCHANNELKEY     = '475'
    ERR_BADCHANMASK       = '476'
    ERR_NOCHANMODES       = '477'
    ERR_BANLISTFULL       = '478'
    ERR_NOPRIVILEGES      = '481'
    ERR_CHANOPRIVSNEEDED  = '482'
    ERR_CANTKILLSERVER    = '483'
    ERR_RESTRICTED        = '484'
    ERR_UNIQOPPRIVSNEEDED = '485'
    ERR_NOOPERHOST        = '491'
    ERR_NOSERVICEHOST     = '492'

    ERR_UMODEUNKNOWNFLAG  = '501'
    ERR_USERSDONTMATCH    = '502'
end
