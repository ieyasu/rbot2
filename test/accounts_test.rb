require 'dbtest'
require 'rubybot2/commands/accounts'

class TestAccounts < Test::Unit::TestCase
    include DBTest

    def setup
        DBTest.setup
        @accounts = Accounts.new(nil)
    end

    def test_register_accounts
        r = flexmock('r')
        r.should_receive(:priv_reply).with('created account account for you; now add nicks with the addnick command').once
        @accounts.c_register(Message.new('nick'), 'account pass', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('account account already exists').once
        @accounts.c_register(Message.new('nick'), 'account pass', r)
    end

    def test_register_bad_args
        r = flexmock('r')
        r.should_receive(:priv_reply).with(Accounts::REGISTER_SYNTAX).twice
        @accounts.c_register(Message.new('nick'), 'foo', r)
        @accounts.c_register(Message.new('nick'), 'foo bar baz', r)
    end

    def test_unregister_accounts
        populate_db
        r = flexmock('r')
        r.should_receive(:priv_reply).with('bad password for account account').once
        @accounts.c_unregister(Message.new('nick'), 'account bass', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with("deleted account account and any registered nicks; if you didn't mean to do this, pray to <deity> that the admin has backups").once
        @accounts.c_unregister(Message.new('nick'), 'account pass', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with('unknown account account').once
        @accounts.c_unregister(Message.new('nick'), 'account pass', r)
    end

    def test_unregister_bad_args
        r = flexmock('r')
        r.should_receive(:priv_reply).with(Accounts::UNREGISTER_SYNTAX).twice
        @accounts.c_unregister(Message.new('nick'), 'foo', r)
        @accounts.c_unregister(Message.new('nick'), 'foo bar baz', r)
    end

    def test_addnick
        populate_db
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('bad password for account account2').once
        @accounts.c_addnick(Message.new('nick'),  'account2 bass', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with('someone else has already added the nick nick to their account').once
        @accounts.c_addnick(Message.new('nick'),  'account2 pass2', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('added nick nick2 to account account2').once
        @accounts.c_addnick(Message.new('nick2'), 'account2 pass2', r)
    end

    def test_addnick_bad_args
        r = flexmock('r')
        r.should_receive(:priv_reply).with(Accounts::ADDNICK_SYNTAX).twice
        @accounts.c_addnick(Message.new('nick'), 'foo', r)
        @accounts.c_addnick(Message.new('nick'), 'foo bar baz', r)
    end

    def test_delnick
        populate_db
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('bad password for account account').once
        @accounts.c_delnick(Message.new('nick'), 'account bass', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('removed nick nick from account account').once
        @accounts.c_delnick(Message.new('nick'), 'account pass', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('account account2 does not own nick nick').once
        @accounts.c_delnick(Message.new('nick'), 'account2 pass2', r)
    end

    def test_delnick_bad_args
        r = flexmock('r')
        r.should_receive(:priv_reply).with(Accounts::DELNICK_SYNTAX).twice
        @accounts.c_delnick(Message.new('nick'), 'foo', r)
        @accounts.c_delnick(Message.new('nick'), 'foo bar baz', r)
    end

    def test_setpass
        populate_db
        r = flexmock('r')
        r.should_receive(:priv_reply).
            with('bad password for account account').once
        @accounts.c_setpass(Message.new('nick'), 'bass newpass', r)
        r = flexmock('r')
        r.should_receive(:priv_reply).with('password updated').once
        @accounts.c_setpass(Message.new('nick'), 'pass newpass', r)
    end

    def test_setpass_bad_args
        r = flexmock('r')
        r.should_receive(:priv_reply).with(Accounts::SETPASS_SYNTAX).twice
        @accounts.c_setpass(Message.new('nick'), 'foo', r)
        @accounts.c_setpass(Message.new('nick'), 'foo bar baz', r)
    end

    def test_setzip
        populate_db
        r = flexmock('r')
        r.should_receive(:priv_reply).with('zip updated').once
        @accounts.c_setzip(Message.new('nick'), '12345', r)
        zip = $dbh.cell("SELECT zip FROM accounts WHERE name = 'account';")
        assert_equal(12345, zip)
    end

    def test_setzip_bad_args
        r = flexmock('r')
        r.should_receive(:priv_reply).with(Accounts::SETZIP_SYNTAX).twice
        @accounts.c_setzip(Message.new('nick'), '', r)
        @accounts.c_setzip(Message.new('nick'), 'foo', r)
    end

    def test_accounts
        r = flexmock('r')
        r.should_receive(:reply).
            with('there are no accounts in the system').once
        @accounts.c_accounts(Message.new('nick'), '', r)
        setup
        populate_db
        r = flexmock('r')
        r.should_receive(:reply).with('accounts: account, account2').once
        @accounts.c_accounts(Message.new('nick'), '', r)
    end

    def test_nicks
        populate_db
        r = flexmock('r')
        r.should_receive(:reply).with('account blah does not exist').once
        @accounts.c_nicks(Message.new('nick'), 'blah', r)
        r = flexmock('r')
        r.should_receive(:reply).with('account account2 has no nicks').once
        @accounts.c_nicks(Message.new('nick'), 'account2', r)
        r = flexmock('r')
        r.should_receive(:reply).
            with('account account has the nicks: nick, unauthnick').once
        @accounts.c_nicks(Message.new('nick'), 'account', r)
    end
end
