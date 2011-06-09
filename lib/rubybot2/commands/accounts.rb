require 'rubybot2/db'
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
    if account_exists?(account)
      r.priv_reply("account #{account} already exists")
    else
      DB[:accounts].insert(account, $rbconfig['default-zip'],hash_passwd(pass))
      r.priv_reply("created account #{account} for you; now add nicks with the addnick command")
    end
  rescue RuntimeError
    r.priv_reply(REGISTER_SYNTAX)
  end

  # unregister an account
  def c_unregister(msg, args, r)
    account, pass = split_2_args(args)
    if check_passwd(account, pass, r)
      destroy(account)
      r.priv_reply("deleted account #{account} and any registered nicks; if you didn't mean to do this, pray to <deity> that the admin has backups")
    end
  rescue RuntimeError
    r.priv_reply(UNREGISTER_SYNTAX)
  end

  # add current nick to an account
  def c_addnick(msg, args, r)
    account, pass = split_2_args(args)
    if check_passwd(account, pass, r)
       DB[:nick_accounts].insert(msg.nick, account)
      r.priv_reply("added nick #{msg.nick} to account #{account}")
    end
  rescue Sequel::DatabaseError
    r.priv_reply("someone else has already added the nick #{msg.nick} to their account")
  rescue RuntimeError
    r.priv_reply(ADDNICK_SYNTAX)
  end

  # delete a nick from an account
  def c_delnick(msg, args, r)
    account, pass = split_2_args(args)
    if check_passwd(account, pass, r)
      na = DB[:nick_accounts].filter(:nick => msg.nick, :account => account)
      case na.delete
      when 1
        r.priv_reply("removed nick #{msg.nick} from account #{account}")
      when 0
        r.priv_reply("account #{account} does not own nick #{msg.nick}")
      else
        raise "AIEEE Shouldn't be able to delete that many"
      end
    end
  rescue RuntimeError => e
    r.priv_reply(DELNICK_SYNTAX)
  end

  # change an account's password
  def c_setpass(msg, args, r)
    oldpass, newpass = split_2_args(args)
    account = Account.ds_by_nick(msg.nick)
    if check_passwd(account, oldpass, r)
      account.update(:passwd => hash_passwd(newpass))
      r.priv_reply("password updated")
    end
  rescue RuntimeError
    r.priv_reply(SETPASS_SYNTAX)
  end

  # change an account's zip
  def c_setzip(msg, args, r)
    zip, pass = split_2_args(args)
    account = Account.ds_by_nick(msg.nick)
    if check_passwd(account, pass, r)
      account.update(:zip => zip)
      r.priv_reply("zip updated to #{zip}")
    end
  rescue RuntimeError
    r.priv_reply(SETZIP_SYNTAX)
  end

  # list the accounts in the system
  def c_accounts(msg, args, r)
    accounts = DB[:accounts].select_col(:name)
    r.reply(accounts.length > 0 ? "accounts: #{accounts.join(', ')}" :
            "there are no accounts in the system")
  end

  # list the nicks belonging to an account
  def c_nicks(msg, args, r)
    raise '' unless args.length > 0
    accounts = DB[:nick_accounts].filter(:account => args).select_col(:nick)
    if accounts
      r.reply("account #{args} has the nicks: #{accounts.join(', ')}")
    elsif account_exists?(args)
      r.reply("account #{args} has no nicks")
    else
      r.reply("account #{args} does not exist")
    end
  rescue RuntimeError
    r.reply(NICKS_SYNTAX)
  end

  private

  def destroy(account)
    DB[:accounts].filter(:name => account).delete
    DB[:nick_accounts].filter(:account => account).delete

    ar = DB[:account_recips].filter(:account => account)
    ids = ar.filter('next_id NOT IN (SELECT next_id FROM pattern_recips)').
      all.map {|row| row[:next_id]}
    ar.delete
    DB[:nexts].filter(:id => ids).delete if ids.length > 0
    DB[:received_nexts].filter(:account => account).delete
  end

  def split_2_args(args)
    ary = args.split
    raise '' if ary.length != 2
    ary
  end

  # Returns true if the account name and password match.
  def check_passwd(account, trypass, r)
    account = DB[:accounts].filter(:name => account) if String === account
    account = account.first
    if account
      name = account[:name]
      salt, pass = account[:passwd].split(':')
      md5 = MD5.new(salt + trypass)
      return true if md5.hexdigest == pass
      r.reply("bad password for account #{name}")
    else
      r.priv_reply("unknown account #{account}")
    end
    false
  end

  def account_exists?(account)
    DB[:accounts].filter(:name => account).count > 0
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
