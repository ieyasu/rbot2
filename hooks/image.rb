m = match_args(/(.+)/, "<search terms>")
body = http_get("http://images.google.com/images\?q=#\&ie=UTF-8\&oe=UTF-8\&hl=en", $args)
if body.index(/<a href=\/imgres\?imgurl=([^&]+)/)
  reply $1
else
  reply "no image was found for #{$args}"
end
