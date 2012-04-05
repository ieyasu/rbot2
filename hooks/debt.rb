doc = Nokogiri::HTML(read_url('http://brillig.com/debt_clock'))
debt = doc.xpath('//img').first[:alt].gsub(/\s/, '')
reply "US National Debt is: #{debt}"
