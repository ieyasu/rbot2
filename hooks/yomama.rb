doc = noko_get("http://www.yomamajokesdb.com/random-joke/")
reply doc.css('div#random').text.gsub(/\.$/, '')
