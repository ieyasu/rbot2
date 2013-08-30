require 'rss'
rss = RSS::Parser.parse("http://news.google.com/news/feeds?q=#{$args}&output=rss", false)
if rss && rss.channel.items.count > 0 then
  reply rss.channel.items.first.title
else
  reply "No news found.  No news is good news?"
end

