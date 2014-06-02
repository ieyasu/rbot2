match_args /\S+/, '<thing>'
node = noko_get("http://www.metacritic.com/search/all/#/results", $args).css('.main_stats').first
title = node.css('.product_title').text
score = node.css('.metascore').text
reply "#{title} #{score}"
