def parse_body(body)
  i = body.index(/<span[^>]+quality="DONT-KNOW"/)
  if i
    i = body.index('<P', i) or return
    j = body.index('P>', i + 3) or return
    j = body.rindex('<', j) or return
  else
    i = body.index(/<span[^>]+quality="(?:PREFACE|MISSPELLED-WORD)"/) or return
    i ||= body.index(/<span type="reply" quality="T"/, i) 
    j = body.index(/<span[^>]+quality="APPENDIX"/) ||
      body.index(/<EM>Abort/) or return
  end
  strip_html body[i...j]
end

begin
  body = http_get("http://start.csail.mit.edu/startfarm.cgi?query=#", $args)
  if body && (answer = parse_body(body))
    reply answer
  else
    reply "error parsing answer for #{$args}"
  end
rescue OpenURI::HTTPError => e
  reply "error asking about #{$args}: #{e.message}"
end
