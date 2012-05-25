#!/usr/bin/env ruby

require 'rubygems'
require 'digest/md5'
load 'config.rb'
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

account = Account.ds_by_nick(ARGV[0])
newpass = ARGV[1]
account.update(:passwd => hash_passwd(newpass))
