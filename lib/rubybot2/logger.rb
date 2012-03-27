require 'logger'

module RbotLogger
    def self.open_log(rotate = true)
        self.rotate_log_file if rotate
        l = Logger.new(EchoIO.new(File.open(LOG_FILE, 'a')))
        l.formatter = RbotLogger::Formatter.new
        l.level = Logger::Severity::DEBUG
        def l.exception(e)
            msg = "!!! caught exception: #{e.inspect}"
            error "#{msg}\n#{e.backtrace.join("\n")}"
            msg
        end
        l
    end
    private
    LOG_FILE = 'log/rbot.log'

    class Formatter
        TIMESTAMP_FMT = '%b %d %H:%M:%S'

        def call(severity, time, progname, msg)
            "#{severity[0,1]} #{time.strftime(TIMESTAMP_FMT)} #{msg2str(msg)}\n"
        end

        # Ripped from Logger::Format (wish it hadn't been made private)
        def msg2str(msg)
            case msg
            when ::String
                msg
            when ::Exception
                "#{msg.message} (#{msg.class})\n" <<
                    (msg.backtrace || []).join("\n")
            else
                msg.inspect
            end
        end
    end

    class EchoIO
        def initialize(io)
            @io = io
        end

        def write(s)
            STDERR.print(s)
            @io.write(s)
            @io.flush
        end

        def close
            @io.close
        end
    end

    def self.rotate_log_file
        if File.exist?(LOG_FILE)
            num = '.000'
            begin
                logfile = LOG_FILE + num
                num.succ!
            end while Dir[logfile + '*'].length > 0
            File.rename(LOG_FILE, logfile)
        end
    end
end
