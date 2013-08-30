require 'rss'
rss = RSS::Parser.parse("http://news.google.com/news/feeds?q=#{$args}&output=rss", false)
if rss.feed_type == 'rss' then
  p rss.channel.items.first.title
else
  p "No news found.  No news is good news?"
end

