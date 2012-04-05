m = match_args(/(.+)/, "<search terms>")
body = read_url("http://images.google.com/images\?q=#{CGI.escape($args)}\&ie=UTF-8\&oe=UTF-8\&hl=en")
if body.index(/<a href=\/imgres\?imgurl=([^&]+)/)
  reply $1
else
  reply "no image was found for #{$args}"
end
