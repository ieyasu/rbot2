require 'dbtest'
require 'rubybot2/commands/whatis'

class TestWhatis < Test::Unit::TestCase
    include DBTest

    def setup
        DBTest.setup
        @whatis = Whatis.new(nil)
    end

    def test_whatis_noargs
        r = flexmock('r')
        r.should_receive(:reply).with(Whatis::WHATIS_SYNTAX).once
        @whatis.c_whatis(Message.new('nick'), '', r)
    end

    def test_whatis_unknown
        r = flexmock('r')
        r.should_receive(:reply).with("blech not found").once
        @whatis.c_whatis(Message.new('nick'), 'blech', r)
    end

    def test_whatis_known
        populate_db
        r = flexmock('r')
        r.should_receive(:reply).with("person taught me that foo == bar").once
        @whatis.c_whatis(Message.new('nick'), 'foo', r)
    end

    def test_forget_unknown
        r = flexmock('r')
        r.should_receive(:reply).with("don't know about blech").once
        @whatis.c_forget(Message.new('nick'), 'blech', r)
    end

    def test_forget_known
        populate_db
        r = flexmock('r')
        r.should_receive(:reply).
            with("forgot that person taught me foo == bar").once
        @whatis.c_forget(Message.new('nick'), 'foo', r)
    end

    def test_remember_known
        populate_db
        r = flexmock('r')
        r.should_receive(:reply).
            with("person already taught me that foo == bar").once
        @whatis.c_remember(Message.new('nick'), 'foo == baz', r)
    end

    def test_remember_unknown
        r = flexmock('r')
        r.should_receive(:reply).
            with("okay, foo == baz").once
        @whatis.c_remember(Message.new('nick'), 'foo == baz', r)
        r = flexmock('r')
        r.should_receive(:reply).with("nick taught me that foo == baz").once
        @whatis.c_whatis(Message.new('nick'), 'foo', r)
    end

    def test_mremember
        r = flexmock('r')
        r.should_receive(:reply).
            with("okay, foo == baz\\7\n  biff").once
        @whatis.c_mremember(Message.new('nick'), 'foo == baz\\\\7\\n  biff', r)
    end
end
