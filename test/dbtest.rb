require 'rubygems'
require 'test/unit'
require 'flexmock'

$LOAD_PATH.unshift('../lib/rubybot2')

require 'rubybot2/db'
$rbconfig = {
    'db-file' => 'test.db'
}

Message = Struct.new(:nick)

module DBTest
    include FlexMock::TestCase

    BACK_IN_TIME = 586

    def self.setup
        File.unlink($rbconfig['db-file']) rescue nil
        `sqlite3 #{$rbconfig['db-file']} '.read ../db/dbdef.sql'`
        $dbh = DB.handle
    end

    def teardown
        DB.close
        File.unlink($rbconfig['db-file'])
    end

    def populate_db
        `sqlite3 #{$rbconfig['db-file']} '.read testdb.sql'`
        DB.close
        $dbh = DB.handle
        $dbh.exec("UPDATE nexts SET sent_at = sent_at - 1168758290 + ?;",
                  Time.now.to_i - BACK_IN_TIME)
    end
end
