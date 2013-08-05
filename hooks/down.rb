m = match_args /^(?:[^\.]+\.)+[^\.]+$/, '<domain.tld>'
doc = noko_get("http://www.isup.me/#{$args}")
resp = doc.css('#container').text
reply resp.gsub(/Check another.*/m, '').strip.squeeze(' ')
