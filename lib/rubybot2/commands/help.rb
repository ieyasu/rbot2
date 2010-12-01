class Help
    def initialize(client)
    end

    def c_help(msg, args, r)
        if args =~ /^!?(\S+)/
            help_for($1, r)
        else
            list_commands(r)
            r.priv_reply('See also http://rubybot.f3h.com/user_accounts.html')
            r.priv_reply("/msg #{$rbconfig['irc_nick']} help <command> for more information")
       end
    end

    private

    HELP_FILE = 'db/HELP_LIST'

    def help_for(command, r)
        IO.read(HELP_FILE).split("\n").each do |line|
            cmd, args, help = line.split('%', 3)
            if cmd == command
                r.priv_reply("Usage: !#{cmd} #{args} - #{help}")
                return
            end
        end
        r.priv_reply("Unknown command #{command}")
    end

    def list_commands(r)
        msg_commands = $rbconfig['msg-commands']
        list = IO.read(HELP_FILE).split("\n").map do |line|
            cmd = line[0...line.index('%')]
            cmd << '*' if msg_commands.member?(cmd)
            cmd
        end.join(', ')
        r.priv_reply("Commands: " + list)
        r.priv_reply('* = /msg only')
    end
end
