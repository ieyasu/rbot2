require 'json'
body = http_get("http://data.mtgox.com/api/2/BTCUSD/money/ticker", $args)
d = JSON.parse(body)['data']
reply "Mt Gox: Last: #{d['last']['display']}, High: #{d['high']['display']}, Low: #{d['low']['display']}, Volume: #{d['vol']['display'].sub("\u00A0BTC", "")}, Weighted Avg: #{d['avg']['display']}"
