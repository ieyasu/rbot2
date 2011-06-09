require 'rubygems'
require 'sequel'
require 'thread'

DB = Sequel.connect($rbconfig['db-uri'])

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
  def filter_regex(col, regex)
    seq = regex.to_s.scan(/\w{3,}/).sort_by {|w| w.length}.last
    ds = seq ? filter(col.like("%#{seq}%")) : self
    regex = Regexp.new(regex, Regexp::IGNORECASE) if String === regex
    ds.all.find {|row| row[col] =~ regex}
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

  def Account.zip_by_nick(nick)
    DB[:accounts].join(:nick_accounts, :account => :name).
      filter(:nick_accounts__nick => nick).select(:zip).first[:zip]
  end
end
