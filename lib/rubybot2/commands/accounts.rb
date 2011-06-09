require 'rubybot2/simple_account'
require 'md5'

class Accounts
    REGISTER_SYNTAX   = 'Usage: !register <account-name> <password>'
    UNREGISTER_SYNTAX = 'Usage: !unregister <account-name> <password>'
    ADDNICK_SYNTAX    = 'Usage: !addnick <account-name> <password>'
    DELNICK_SYNTAX    = 'Usage: !delnick <account-name> <password>'
    SETPASS_SYNTAX    = 'Usage: !setpass <old-pass> <new-pass>'
    SETZIP_SYNTAX     = 'Usage: !setzip <zip> <password>'
    NICKS_SYNTAX      = 'Usage: !nicks <account-name>'

    def initialize(client)
    end

    # register a new account
    def c_register(msg, args, r)
        account, pass = split_2_args(args)
        DB.lock do |dbh|
            if account_exists?(account, dbh)
                r.priv_reply("account #{account} already exists")
            else
                dbh.exec("INSERT INTO accounts VALUES(?,?,?);", account,
                         $rbconfig['default-zip'], hash_passwd(pass))
                r.priv_reply("created account #{account} for you; now add nicks with the addnick command")
                DB.close
            end
        end
    rescue RuntimeError
        r.priv_reply(REGISTER_SYNTAX)
    end

    # unregister an account
    def c_unregister(msg, args, r)
        account, pass = split_2_args(args)
        DB.lock do |dbh|
            if check_passwd(account, pass, r, dbh)
                destroy(account, dbh)
                r.priv_reply("deleted account #{account} and any registered nicks; if you didn't mean to do this, pray to <deity> that the admin has backups")
            end
        end
    rescue RuntimeError
        r.priv_reply(UNREGISTER_SYNTAX)
    end

    # add current nick to an account
    def c_addnick(msg, args, r)
        account, pass = split_2_args(args)
        DB.lock do |dbh|
            if check_passwd(account, pass, r, dbh)
                dbh.exec("INSERT INTO nick_accounts VALUES(?,?,?);",
                         msg.nick, account, 1)
                r.priv_reply("added nick #{msg.nick} to account #{account}")
            end
        end
    rescue SQLite3::Exception
        r.priv_reply("someone else has already added the nick #{msg.nick} to their account")
    rescue RuntimeError
        r.priv_reply(ADDNICK_SYNTAX)
    end

    # delete a nick from an account
    def c_delnick(msg, args, r)
        account, pass = split_2_args(args)
        DB.lock do |dbh|
            if check_passwd(account, pass, r, dbh)
                n = dbh.exec("DELETE FROM nick_accounts WHERE
                              nick = ? AND account = ?;", msg.nick, account)
                if n == 1
                    r.priv_reply("removed nick #{msg.nick} from account #{account}")
                elsif n == 0
                    r.priv_reply("account #{account} does not own nick #{msg.nick}")
                else
                    raise "AIEEE Shouldn't be able to delete that many"
                end
            end
        end
    rescue RuntimeError => e
        r.priv_reply(DELNICK_SYNTAX)
    end

    # change an account's password
    def c_setpass(msg, args, r)
        oldpass, newpass = split_2_args(args)
        DB.lock do |dbh|
            account = Account.by_nick(msg.nick, dbh)
            if check_passwd(account, oldpass, r, dbh)
                dbh.exec("UPDATE accounts SET passwd = ? WHERE name = ?;",
                         hash_passwd(newpass), account)
                r.priv_reply("password updated")
            end
        end
    rescue RuntimeError
        r.priv_reply(SETPASS_SYNTAX)
    end

    # change an account's zip
    def c_setzip(msg, args, r)
        zip, pass = split_2_args(args)
        DB.lock do |dbh|
            account = Account.by_nick(msg.nick, dbh)
            if check_passwd(account, pass, r, dbh)
                dbh.exec("UPDATE accounts SET zip = ? WHERE name = ?;",
                         args, account)
                r.priv_reply("zip updated")
            end
        end
    rescue RuntimeError
        r.priv_reply(SETZIP_SYNTAX)
    end

    # list the accounts in the system
    def c_accounts(msg, args, r)
        DB.lock do |dbh|
            accounts = dbh.cells("SELECT name FROM accounts;")
            r.reply(accounts ? "accounts: #{accounts.join(', ')}" :
                        "there are no accounts in the system")
        end
    end

    # list the nicks belonging to an account
    def c_nicks(msg, args, r)
        raise '' unless args.length > 0
        DB.lock do |dbh|
            accounts = dbh.cells("SELECT nick FROM nick_accounts
                                  WHERE account = ?;", args)
            if accounts
                r.reply("account #{args} has the nicks: #{accounts.join(', ')}")
            elsif account_exists?(args, dbh)
                r.reply("account #{args} has no nicks")
            else
                r.reply("account #{args} does not exist")
            end
        end
    rescue RuntimeError
        r.reply(NICKS_SYNTAX)
    end

    private

    def destroy(account, dbh)
        dbh.exec("DELETE FROM accounts WHERE name = ?;", account)
        dbh.exec("DELETE FROM nick_accounts WHERE account = ?;", account)
        ids = dbh.cells("SELECT next_id FROM account_recips
                             WHERE account = ? AND next_id NOT IN
                             (SELECT next_id FROM pattern_recips);")
        dbh.exec("DELETE FROM account_recips WHERE account = ?;", account)
        if ids && ids.length > 0
            dbh.exec("DELETE FROM nexts WHERE id IN (#{ids.join(',')});")
        end
        dbh.exec("DELETE FROM received_nexts WHERE account = ?;", account)
    end

    def split_2_args(args)
        ary = args.split
        raise '' if ary.length != 2
        ary
    end

    # Returns true if the account name and password match.
    def check_passwd(account, trypass, r, dbh)
        pass = dbh.cell("SELECT passwd FROM accounts WHERE name = ?;",
                        account) or raise "unknown account #{account}"
        salt, pass = pass.split(':')
        md5 = MD5.new(salt + trypass)
        (md5.hexdigest == pass) || raise("bad password for account #{account}")
    rescue RuntimeError => e
        r.priv_reply(e.message)
    end

    def account_exists?(account, dbh)
        dbh.cell("SELECT COUNT(*) FROM accounts where name = ?;",
                  account).to_i > 0
    end

    # Returns the salted, hashed password ready to store in the db
    def hash_passwd(pass)
        salt = ''
        File.open('/dev/urandom') do |fin|
            6.times { salt << sprintf("%x", fin.getc) }
        end
        "#{salt}:#{MD5.new(salt + pass).hexdigest}"
    end
end
