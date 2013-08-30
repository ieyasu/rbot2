require 'rss'
rss = RSS::Parser.parse("http://news.google.com/news/feeds?q=#{$args}&output=rss", false)
if rss.feed_type == 'rss' then
  reply rss.channel.items.first.title
else
  reply "No news found.  No news is good news?"
end

