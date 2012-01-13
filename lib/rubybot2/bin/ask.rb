#!/usr/bin/env ruby

def parse_body(body)
  i = body.index(/<span[^>]+quality="DONT-KNOW"/)
  if i
    i = body.index('<P', i) or return
    j = body.index('P>', i + 3) or return
    j = body.rindex('<', j) or return
  else
    i = body.index(/<span[^>]+quality="PREFACE"/) || 0
    i = body.index(/<span type="reply" quality="T"/, i) or return
    j = body.index(/<span[^>]+quality="APPENDIX"/) or return
  end
  strip_html body[i...j]
end

def handle_command(nick, dest, args)
  body = open("http://start.csail.mit.edu/startfarm.cgi?query=#{CGI.escape(args)}").read
  if body && (answer = parse_body(body))
    "P\t#{answer}"
  else
    "P\terror parsing answer for #{args}"
  end
rescue OpenURI::HTTPError => e
  "P\terror asking about #{args}: #{e.message}"
end

load 'boilerplate.rb'
