class Raw
    RAW_SYNTAX = 'Usage: !raw <admin-pass> <raw irc command>'

    def initialize(client)
        @client = client
    end

    def c_raw(msg, args, r)
        pass, irc_command = args.split(nil, 2)
        raise '' unless pass && irc_command
        if pass == $rbconfig['admin-passwd']
            r.priv_reply("sending raw irc message '#{irc_command}'")
            r.raw(irc_command)
        else
            r.priv_reply('admin password does not match')
        end
    rescue RuntimeError
        r.priv_reply(RAW_SYNTAX)
    end
end
