require 'date'

ragequits = Array.new

ragequits.push(:name => 'galen', :date => Date.new(2012, 5, 7), :quote => "A sandy vag is never good.")
ragequits.push(:name => 'bishop', :date => Date.new(2013, 2, 8), :quote => "and fuck off with that little man shit")

ragequits.each {|r| reply "#{r[:name]} ragequit on #{r[:date]} (#{(Date.today - r[:date]).to_i.abs} days ago): #{r[:quote]}"}
