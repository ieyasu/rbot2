#!/usr/bin/env ruby

require 'md5'
require 'config'
require 'rubybot2/db'

# Returns the salted, hashed password ready to store in the db
def hash_passwd(pass)
    salt = ''
    File.open('/dev/urandom') do |fin|
        6.times { salt << sprintf("%x", fin.getc) }
    end
    "#{salt}:#{MD5.new(salt + pass).hexdigest}"
end

unless ARGV.length == 2
    puts "Usage: account newpass"
    exit 1
end
account, newpass = ARGV[0], ARGV[1]

DB.lock do |dbh|
    dbh.exec("UPDATE accounts SET passwd = ? WHERE name = ?;",
             hash_passwd(newpass), account)
end
