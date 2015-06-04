require 'sequel'
require 'thread'

if $rbconfig['db-uri'] =~ /sqlite/
  # cannot catch exception and reconnect; lock still in place; just don't do concurrent access
  DB = Sequel.connect($rbconfig['db-uri'], :max_connections => 1)
else
  DB = Sequel.connect($rbconfig['db-uri'])
end

# sanitizes name-like values for DB columns
def db_sanitize_name(name)
  (i = name.index(';')) and name = name[0...i]
  name.scan(/[\w\s]+/).join
end

class Sequel::Dataset
  # Looks for the substring term in the given column, after sanitizing term.
  def sanilike(col, term)
    san = db_sanitize_name(term)
    san.length > 0 ? filter(col.like("%#{san}%")) : self
  end

  # Scans the result set for a regex match in given column, pre-filtering
  # when the regex has a long word char subsequence.
  def all_regex(col, regex)
    regex = Regexp.new(regex, Regexp::IGNORECASE) if String === regex
    self.all.find_all {|row| row[col] =~ regex}
  end

  def first_regex(col, regex)
    regex = Regexp.new(regex, Regexp::IGNORECASE) if String === regex
    self.all.find {|row| row[col] =~ regex}
  end

  # Matches thing against the regular expressions in the given column.
  def regex_col(col, thing)
    all.find_all {|row| Regexp.new(row[col], Regexp::IGNORECASE) =~ thing}
  end

  # Returns an array result containing only the values of the requested column
  def select_col(col)
    select(col).all.map { |row| row[col]}
  end
end

module Account
  # Returns the account dataset by the given nickname
  def Account.ds_by_nick(nick)
    na = DB[:nick_accounts].filter(:nick => nick).first
    DB[:accounts].filter(:name => na[:account]) if na
  end

  def Account.by_nick(nick)
    a = Account.ds_by_nick(nick) and a.first
  end

  def Account.name_by_nick(nick)
    a = Account.by_nick(nick) and a[:name]
  end

  def Account.zip_by_nick(nick)
    a = Account.by_nick(nick)
    a ? a[:zip] : $rbconfig['default-zip']
  end

  def Account.pws_by_nick(nick)
    a = Account.by_nick(nick)
    a ? a[:pws] : nil
  end
end
