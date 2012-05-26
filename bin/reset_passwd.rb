#!/usr/bin/env ruby

require 'rubygems'
require 'digest/md5'
load 'config.rb'
require 'rubybot2/db'
require 'rubybot2/account'

unless ARGV.length == 2
    puts "Usage: account newpass"
    exit 1
end

account, newpass = ARGV
puts DB[:accounts].filter(:name => account).update(:passwd => Account::hash_passwd(newpass))
