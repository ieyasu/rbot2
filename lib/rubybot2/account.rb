require 'rubybot2/db'
require 'digest/md5'
include Digest

module Account
  def Account.create(name, zip, pass)
    DB[:accounts].insert(name, zip, Account::hash_passwd(pass))
  end

  # delete everything belonging to the named account from the database.
  def Account.destroy(account)
    DB[:accounts].filter(:name => account).delete
    DB[:nick_accounts].filter(:account => account).delete

    ar = DB[:account_recips].filter(:account => account)
    ids = ar.filter('next_id NOT IN (SELECT next_id FROM pattern_recips)').
      all.map {|row| row[:next_id]}
    ar.delete
    DB[:nexts].filter(:id => ids).delete if ids.length > 0
    DB[:received_nexts].filter(:account => account).delete
  end

  # Returns true if the account name and password match.
  def Account.check_passwd(account, trypass, r = nil)
    account = DB[:accounts].filter(:name => account) if String === account
    account = account.first if account
    if account
      name = account[:name]
      salt, pass = account[:passwd].split(':')
      md5 = MD5.hexdigest(salt + trypass)
      return true if md5 == pass
      r && r.reply("bad password for account #{name}")
    else
      r && r.priv_reply("unknown account #{account}")
    end
    false
  end

  def Account.exists?(account)
    DB[:accounts].filter(:name => account).count > 0
  end

  def Account.by_name(name)
    DB[:accounts].filter(:name => name).first
  end

  def Account.list_nicks(account)
    DB[:nick_accounts].filter(:account => account).select_col(:nick)
  end

  def Account.add_nick(account, nick)
    DB[:nick_accounts].insert(nick, account)
    return true, "added nick #{nick} to account #{account}"
  rescue Sequel::DatabaseError
    return false, "someone else has already added the nick #{nick} to their account"
  end

  def Account.del_nick(account, nick)
    na = DB[:nick_accounts].filter(:nick => nick, :account => account)
    case na.delete
    when 1
      return true, "removed nick #{nick} from account #{account}"
    when 0
      reutrn false, "account #{account} does not own nick #{nick}"
    else
      raise "AIEEE Shouldn't be able to delete that many"
    end
  end

  # Returns the salted, hashed password ready to store in the db
  def Account.hash_passwd(pass)
    salt = ''
    File.open('/dev/urandom') do |fin|
      6.times { salt << sprintf("%x", fin.getbyte) }
    end
    "#{salt}:#{MD5.hexdigest(salt + pass)}"
  end
end
