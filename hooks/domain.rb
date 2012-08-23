require 'shellwords'

match_args(/.+/, "<domain.tld>")

resp = `whois '#{Shellwords.shellescape $args}'`
if resp =~ /expir(?:es|ation)(?:\s+on)?(?:\s+date)?(?:[^:\r\n]*:)?\s*(\S+)/i
  reply "#{$args} expires #{$1.strip}"
elsif resp =~ /No match for/ or resp =~ /No.*this kind of object/
  reply "#{$args} available"
else
  reply "Parse error in whois response for #{$args}"
end

#      Record expires on 2013-08-10
#    Expires on..............: 2020-09-13.
#registration-expiration:         26-Apr-2013
#      Expires on: 06-Sep-12
#Expiration Date: 2013-05-10 18:17:39
