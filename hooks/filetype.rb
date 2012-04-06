m = match_args /\.?(\w+)/, '<extension>'
doc = noko_get("http://www.fileinfo.com/extension/#", m[1])
reply doc.css('td.description p').text
