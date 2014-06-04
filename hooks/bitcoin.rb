require 'json'
body = http_get("https://blockchain.info/ticker", $args)
d = JSON.parse(body)['USD']
reply "Blockchain (USD): 15m avg: #{d['15m']}, Last: #{d['last']}, Buy: #{d['buy']}, Sell: #{d['sell']}"
