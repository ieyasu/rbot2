#!/usr/bin/env ruby
# Extract TLDs from db/tld.txt into a regex fragment matching all of them

def gather_prefixes(tlds)
  prefixes = []
  while tlds.length > 0
    prefix = tlds.first[0]
    i = tlds.index {|tld| tld[0] != prefix} || tlds.length
    group = tlds[0...i].map {|tld| tld[1..-1]}
    r = (group.length == 1) ? group.first : gather_prefixes(group)
    prefixes << "#{prefix}#{r}"
    tlds = tlds[i..-1]
  end
  "(?:#{prefixes.join('|')})"
end


# ---

tlds = []
File.open(File.dirname(__FILE__) + '/../db/tld.txt') do |fin|
  fin.each_line do |line|
    line =~ /^\.(\S+)/ and tlds << $1
  end
end
tlds = tlds.sort

r = gather_prefixes(tlds)
puts r
puts

# gather char runs into classes
r = r.gsub(/([:\|])([a-z](?:\|[a-z](?![a-z(]))+(?=[|)]))/) do |m|
  "#{$1}[#{m.scan(/[a-z]/).join}]"
end.gsub(/\(\?:(\[[a-z]+\])\)/, '\\1')
puts r
