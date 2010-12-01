require 'rubybot2/replier'
require 'socket'

class Paster
    def initialize(client)
        @client = client
 
        File.unlink(PASTE_SOCKET) if File.exist?(PASTE_SOCKET)
        @paste_sock = UNIXServer.open(PASTE_SOCKET)
        File.chmod(0777, PASTE_SOCKET)

        @t = Thread.new do
            loop { handle_paste }
        end
    end

    private

    PASTE_SOCKET = '/tmp/paste'

    def handle_paste
        sock = @paste_sock.accept
        if (dest = sock.gets)
            dest = dest.chop
            IRC::Replier.lock do
                sock.each_line do |line|
                    line = line.strip
                    @client.privmsg(dest, line) if line.length > 0
                end
            end
        end
    ensure
        sock.close
    end
end
