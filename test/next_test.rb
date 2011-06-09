require 'dbtest'
require 'rubybot2/commands/next'

class TestNext < Test::Unit::TestCase
    include DBTest

    def setup
        DBTest.setup
        @next = Next.new(nil)
    end

    def test_next1
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('will send `message1` to ^pat').once
        now = Time.now.to_i
        @next.c_next(Message.new('nick'),  '^pat message1', r)
        assert_equal([[1, now, 'nick',nil,'message1']],
                     $dbh.get("SELECT * FROM nexts;"))
        assert_equal([[1, '^pat', '']],
                     $dbh.get("SELECT * FROM pattern_recips;"))
    end

    def test_next2
        populate_db
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('will send `message1` to unau').once
        now = Time.now.to_i
        @next.c_next(Message.new('nick'),  'unau message1', r)
        assert_equal([[7, now, 'nick','account','message1']],
               $dbh.get("SELECT * FROM nexts WHERE message = 'message1';"))
        assert_equal([[7, 'unau', '']],
               $dbh.get("SELECT * FROM pattern_recips WHERE next_id =
                    (SELECT ROWID FROM nexts WHERE message = 'message1');"))
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('will send `message2` to (account)').once
        @next.c_next(Message.new('foo'),  'unau message2', r)
        assert_equal([[8, 'account', '']],
               $dbh.get("SELECT * FROM account_recips WHERE next_id =
                    (SELECT ROWID FROM nexts WHERE message = 'message2');"))
    end

    def test_multi_next
        populate_db
        r = flexmock('r')
        r.should_receive(:priv_reply).with('will send `mnt` to nick, unau, b, d, e').once
        @next.c_next(Message.new('nick'),  'nick;unau;b,d,e: mnt', r)
        assert_equal(5, $dbh.cell("SELECT COUNT(*) FROM pattern_recips
                                   WHERE next_id = 7;").to_i)
        r = flexmock('r')
        r.should_receive(:priv_reply).with('will send `mnt` to b, d, e (account)').once
        @next.c_next(Message.new('anick'),  'nick;unau;b,d,e: mnt', r)
        assert_equal(1, $dbh.cell("SELECT COUNT(*) FROM account_recips
                                   WHERE next_id = 8;").to_i)
        assert_equal(3, $dbh.cell("SELECT COUNT(*) FROM pattern_recips
                                   WHERE next_id = 8;").to_i)
    end

    def test_multi_next_both_receive
        populate_db
        now = Time.now.strftime('[%a %H:%M]')
        r = flexmock('r')
        r.should_receive(:priv_reply).with('will send `mnt` to p1, p2').once
        @next.c_next(Message.new('nick'),  'p1,p2 mnt', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with("#{now} p2 \002p1\002: <nick> mnt")
        @next.c_read(Message.new('p1'), '', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with("#{now} p1 \002p2\002: <nick> mnt")
        @next.c_read(Message.new('p2'), '', r)
    end

    def test_next_bad_args
        r = flexmock('r')
        r.should_receive(:priv_reply).with(Next::NEXT_SYNTAX).once
        @next.c_next(Message.new('nick'), '', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with(Next::NEXT_SYNTAX).once
        @next.c_next(Message.new('nick'), 'blah', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with(Next::NEXT_SYNTAX).once
        @next.c_next(Message.new('nick'), ';, abc', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with('you cannot next more than 7 people at a time').once
        @next.c_next(Message.new('nick'), 'a;b;c:;d:,e,f,g;h too many', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with(Next::NEXT_SYNTAX).once
        @next.c_next(Message.new('nick'), 'a; b cde', r)
    end

    def test_read
        populate_db
        r = flexmock('r')
        r.should_receive(:priv_reply).with('you have no nexts').once
        @next.c_read(Message.new('nonextsforme'), '', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with('you have next(s) which require authentication; please authenticate').once
        @next.c_read(Message.new('unauthnick'), '', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with(/\[[^\]]{9}\] \002account\002: <frm2> msg2/).once
        r.should_receive(:priv_reply).
            with(/\[[^\]]{9}\] \002account\002: <frm3> msg3/).once
        @next.c_read(Message.new('nick'), '', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with(/\[[^\]]{9}\] bar \002foo\002: <frm4> msg4/).once
        @next.c_read(Message.new('foo'), '', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with(/\[[^\]]{9}\] \002ba\002: <frm5> msg5/).once
        r.should_receive(:priv_reply).
            with(/\[[^\]]{9}\] \002ar\002: <frm6> msg6/).once
        @next.c_read(Message.new('bar'), '', r)
    end

    def test_listnexts
        populate_db
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('you must be authenticated to do that!').once
        @next.c_listnexts(Message.new('nonextsforme'), '', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('you must be authenticated to do that!').once
        @next.c_listnexts(Message.new('unauth'), '', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with("0. (tonick): `msg1`").once
        @next.c_listnexts(Message.new('nick'), '', r)
        $dbh.exec("DELETE FROM nexts;")
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('you have no undelivered nexts').once
        @next.c_listnexts(Message.new('nick'), '', r)
    end

    def test_deletelastnext
        populate_db
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('you must be authenticated to do that!').once
        @next.c_deletelastnext(Message.new('unauth'), '', r)
        assert_equal(1, $dbh.cell("SELECT COUNT(*) FROM nexts WHERE
                                   from_nick = 'nick'").to_i)
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with("deleted last undelivered next 'msg1'").once
        @next.c_deletelastnext(Message.new('nick'), '', r)
        assert_equal(0, $dbh.cell("SELECT COUNT(*) FROM nexts WHERE
                                   from_nick = 'nick'").to_i)
    end

    def test_pastnexts
        populate_db
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('you must be authenticated to do that!').once
        @next.c_pastnexts(Message.new('unauth'), '', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with(Next::PAST_SYNTAX).once
        @next.c_pastnexts(Message.new('nick'), 'a', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with(Next::PAST_SYNTAX).once
        @next.c_pastnexts(Message.new('nick'), '5 a', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with('0. [Sat 2007-01-13 15:40] nick (account): <from> a message 3;  1. [Sat 2007-01-13 15:40] nick (account): <from> a message 2;  2. [Sat 2007-01-13 15:40] nick (account): <from> a message 1;  3. [Sat 2007-01-13 15:39] nick (account): <from> a message').once

        @next.c_pastnexts(Message.new('nick'), '', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with('1. [Sat 2007-01-13 15:40] nick (account): <from> a message 2;  2. [Sat 2007-01-13 15:40] nick (account): <from> a message 1').once
        @next.c_pastnexts(Message.new('nick'), '1 2', r)
    end

    def test_pastnexts_none
        populate_db
        $dbh.exec("DELETE FROM received_nexts;")
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('your account has not received any nexts').once
        @next.c_pastnexts(Message.new('nick'), '', r)
    end

    class TestReplier
        def priv_reply(str)
        end
    end
end
