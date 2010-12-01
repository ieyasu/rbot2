require 'rubygems'
require 'sqlite3'
require 'thread'

module DB
    $db_lock = Mutex.new

    def DB.handle
        if defined?($dbh) && $dbh
            $dbh
        else
            dbh = SQLite3::Database.new($rbconfig['db-file'])
            dbh.type_translation = true
            # sql user func regexp(text, pat)
            dbh.create_function('regexp', 2) do |func, text, pat|
                m = unless text.null?
                        Regexp.new(pat.to_s, Regexp::IGNORECASE) =~ text.to_s
                    end
                #puts "/#{pat}/ =~ #{text} => #{m || -1}"
                func.set_result(m ? 't' : 'f')
            end
            $dbh = dbh
        end
    end

    def DB.close
        if $dbh
            $dbh.close if $dbh.closed?
            $dbh = nil
        end
    end

    def DB.lock(&block)
        $client.logger.warn "%%% possible db deadlock" if $db_lock.locked?
        ret = $db_lock.synchronize do
            dbh = DB.handle
            return dbh.transaction do
                return block.call(dbh)
            end
        end
        DB.close
        ret
    end
end

# Add some nice methods to be compatible with my old lib
module SQLite3
    class Database
        def exec(*args)
            res = get_first_value(*args)
            changes
        end

        def get(*args)
            res = execute(*args)
            res.length == 0 ? nil : res
        end

        alias :row :get_first_row
        alias :cell :get_first_value

        def cells(*args)
            res = execute(*args).map { |row| row[0] }
            res.length == 0 ? nil : res
        end
    end

    class Statement
        def exec(*args)
            res = execute(*args).next
            DB.handle.changes
        end

        def get(*args)
            res = execute(*args).map { |row| row }
            res.length == 0 ? nil : res
        end

        def row(*args)
            execute(*args).next
        end

        def cell(*args)
            res = execute(*args).next[0] rescue nil
        end

        def cells(*args)
            res = execute(*args).map { |row| row[0] }
            res.length == 0 ? nil : res
        end
    end
end
