match_args /\S+/, '<search terms>'
resp = Net::HTTP.get_response(URI.parse(
    "http://en.wikipedia.org/wiki/Special:Search?search=#{CGI.escape($args)}"))
reply (resp && resp['location']) ? resp['location'] :
  "couldn't find wikipedia page for '#{args}'"
