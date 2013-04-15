require 'date'

ragequits = Hash.new

ragequits['bishop'] = Date.new(2013, 2, 8)

ragequits.each {|k,v| reply "#{k} ragequit on #{v} (#{(Date.today - v).to_i.abs} days ago)" }
