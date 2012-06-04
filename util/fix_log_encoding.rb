#!/usr/bin/env ruby
# read through logs, print out all non-utf8 lines

Dir['log/#*/*.log'].each do |file|
  s = File.read(file)
  unless s.valid_encoding?
    puts file
    File.rename(file, "BAD-LOG/#{File.basename file}")
    File.open(file, 'w') do |fout|
      fout.puts s.force_encoding("ISO-8859-1").encode("UTF-8")
    end
  end
end
