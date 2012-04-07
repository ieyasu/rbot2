doc = noko_get("https://mtgox.com")
s = %w(lastPrice highPrice lowPrice volume weightedAverage).map do|id|
  doc.css("li##{id}").text.gsub(':', ': ').gsub(/0+$/, '')
end.join(', ')
reply "Mt. Gox: #{s}"
