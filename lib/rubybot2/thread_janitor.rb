class ThreadJanitor
    SLEEP_INTERVAL = 27.7

    def initialize
        @group = ThreadGroup.new
        @watchdog = Thread.new do
            loop do
                sleep SLEEP_INTERVAL
                clean_house
            end
        end
    end

    def register(thread)
        @group.add(thread)
    end

    def clean_house
        @group.list.each do |thread|
            thread.join unless thread.alive?
        end
    end
end
