doc = noko_get('http://brillig.com/debt_clock')
debt = doc.xpath('//img').first[:alt].gsub(/\s/, '')
reply "US National Debt is: #{debt}"
