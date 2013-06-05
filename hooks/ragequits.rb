require 'date'

ragequits = Array.new

ragequits.push(:name => 'galen', :date => Date.new(2012, 5, 7), :quote => "A sandy vag is never good.")
ragequits.push(:name => 'r0s', :date => Date.new(2013, 5, 19), :quote => "J-Roc: fuck you")

ragequits.each {|r| reply "#{r[:name]} ragequit on #{r[:date]} (#{(Date.today - r[:date]).to_i.abs} days ago): #{r[:quote]}"}
