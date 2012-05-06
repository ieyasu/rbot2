require 'rubybot2/db'
require 'digest/md5'
include Digest

module Account
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
  def Account.check_passwd(account, trypass, r)
    account = DB[:accounts].filter(:name => account) if String === account
    account = account.first if account
    if account
      name = account[:name]
      salt, pass = account[:passwd].split(':')
      md5 = MD5.hexdigest(salt + trypass)
      return true if md5 == pass
      r.reply("bad password for account #{name}")
    else
      r.priv_reply("unknown account #{account}")
    end
    false
  end

  def Account.exists?(account)
    DB[:accounts].filter(:name => account).count > 0
  end

  # Returns the salted, hashed password ready to store in the db
  def Account.hash_passwd(pass)
    salt = ''
    File.open('/dev/urandom') do |fin|
      6.times { salt << sprintf("%x", fin.getc.getbyte(0)) }
    end
    "#{salt}:#{MD5.hexdigest(salt + pass)}"
  end
end
