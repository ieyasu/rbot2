require 'whois'

match_args(/.+\..+/, "<domain.tld>")

r = Whois::Client.new.lookup($args)
if r.available?
  reply "#{$args} available"
elsif r.to_s =~ /expir(?:es|ation)(?:\s+on)?(?:\s+date)?(?:[^:\r\n]*:)?\s*(.+)/i
  reply "#{$args} expires #{$1.strip}"
else
  reply "Parse error in whois response for #{$args}"
end

#      Record expires on 2013-08-10
#    Expires on..............: 2020-09-13.
# registration-expiration:         26-Apr-2013
#      Expires on: 06-Sep-12
# Expiration Date: 2013-05-10 18:17:39
# Domain Expiration Date:                      Sat Mar 30 23:59:59 GMT 2013
# Expiration date: 07 Jun 2013 18:29:00
# Expiration date: 29 Apr 2013 15:12:00
