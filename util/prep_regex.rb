#!/usr/bin/env ruby
# Removes comments and whitespaces from url-regex.txt to produce url-regex

while (line = gets)
  if line =~ /^(?!#)/
    print line.strip
  end
end
puts
