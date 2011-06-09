require 'rubybot2/thread_janitor'
require 'rubybot2/db'
require 'cgi'
require 'open-uri'
require 'open3'

# Listens channel and private messages to the bot which instruct it
# to run a command.  There are three different command interfaces:
# internal, implemented as ruby code under commands/; normal commands
# implemented as exec()able scripts under bin/; and php web commands
# accessed by http (see php-root config value).
class CommandRunner
    def initialize(client)
        @client = client
        @janitor = ThreadJanitor.new
        @commands = {}
        load_commands('commands')
    end

    def m_PRIVMSG(msg, r)
        command, args = msg.text.split(nil, 2)
        return unless command =~ /^#{$rbconfig['cmd_prefix']}?[^\/\s]+$/
        command = command[1..-1] if command[0,1] == $rbconfig['cmd_prefix']
        args ||= ''

        # ensure that commands which should be privately-messaged
        # only are in fact messaged so
        msg_only = $rbconfig['msg-commands'].member?(command)
        unless !msg.sent_to_channel? || (msg.text[0,1] == $rbconfig['cmd_prefix'] && !msg_only)
            msg_only && r.priv_msg( "Try: /msg #{
                $rbconfig['nick']} #{msg.text[1..-1]}")
            return
        end

        @janitor.register(Thread.new do
            begin
                cmdsym = "c_#{command}".to_sym
                if (cmd = find_command(cmdsym, msg.dest))
                    cmd.send(cmdsym, msg, args, r)
                elsif (bin = find_bin(command, msg.dest))
                    run_bin(bin, msg, args, r)
                elsif PHP_ROOT
                    call_php(msg, command, args, r)
                end
            rescue Exception => e
                @client.logger.warn("!!! command threw exception #{e.inspect}: #{e.message} #{e.backtrace.join("\n")}")
            end
        end)
    end

    private

    PHP_ROOT = $rbconfig['php-root']
    PHP_ROOT << '/' unless PHP_ROOT[-1,1] == '/'

    def load_commands(path)
        path =~ %r!commands/(.+)!
        chan = $1 || ''
        Dir.foreach(path) do |fn|
            file = "#{path}/#{fn}"
            if (File.file?(file) || File.symlink?(file)) && fn =~ /(\w+)\.rb$/
                @client.logger.info "Loading command #{fn}"
                load file
                cmd = file_to_class(fn).new(@client)
                (@commands[chan] ||= []) << cmd
            elsif File.directory?(fn) && IRC::channel_name?(fn)
                load_command_directory(path)
            end
        end
    end

    def find_command(cmdsym, dest)
        ((@commands[dest] || []) + @commands['']).find do |cmd|
            cmd.respond_to?(cmdsym) ? cmd : nil
        end
    end

    def find_bin(command, dest)
        path = "bin/#{command}"
        if executable?(path)
            path
        elsif IRC::channel_name?(dest)
            path = "bin/#{dest}/#{command}"
            path if executable?(path)
        end
    end

    def executable?(path)
        if File.executable?(path)
            true unless File.directory?(path)
        elsif File.exists?(path)
            @client.logger.warn "!!! #{path} isn't executable"
        end
    end

    def run_bin(bin, msg, args, r)
        args ||= ''
        zip = Account.zip_by_nick(msg.nick) || $rbconfig['default-zip']
        ENV['ZIP'] = zip.to_s
        Open3.popen3(bin, msg.nick, msg.dest, args) do |b_in, b_out, b_err|
            while (line = b_out.gets)
                line = line.rstrip
                r.raw("#{line}\r\n") if line.length > 0
            end
            while (line = b_err.gets)
                line = line.rstrip
                r.reply(line) if line.length > 0
            end
        end
    end

    def call_php(msg, command, args, r)
        result = get_php(msg.nick, msg.dest, command, args) or return
        result.each_line do |line|
            line = line.strip
            if line[0,8] == "\001PRIVATE"
		line = line[9..-1]
                r.priv_reply(line) if line.length > 0
            elsif line[0,7] == "\001ACTION"
                line = line[8..-1]
                r.action(line) if line.length > 0
            elsif line.length > 0
                r.reply(line)
            end
        end
    end

    def get_php(nick, dest, command, args)
        open("#{PHP_ROOT}#{CGI.escape command}.php?source=#{CGI.escape nick}" <<
                 "&dest=#{CGI.escape dest}&args=#{CGI.escape args}") do |sin|
            sin.read
        end
    rescue OpenURI::HTTPError => e
        raise e unless e.message == '404 Not Found'
    end
end
