require 'shellwords'

match_args(/.+/, "<domain.tld>")

resp = `whois '#{Shellwords.shellescape $args}'`
if resp =~ /^\s*Expires on:\s*(.*)/
	reply "#{$args} expires on #{$1}"
elsif resp =~ /^\s*Expiration Date:\s*(.*)/
  reply "#{$args} expires #{$1}"
elsif resp =~ /No match for/ or resp =~ /No.*this kind of object/
  reply "#{$args} available"
else
  reply "Parse error in whois response for #{$args}"
end
