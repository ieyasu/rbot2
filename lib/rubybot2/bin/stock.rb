#!/usr/bin/env ruby

SYNTAX = 'Usage: !stock <symbol>'

def parse_quote(body)
  unless body.index('<table')
    return "Stock symbol not  found"
  end

  i = body.index('<tr') or return
  i = body.index('<tr', i + 3) or return
  i = body.index('<td', i + 3) or return
  j = body.index('</td', i) or return
  company = strip_html(body[i...j])
  #p company

  i = body.index('<td>Last') or return
  i = body.index('<td', i + 3) or return
  j = body.index('</td', i) or return
  price = strip_html(body[i...j])
  #p price

  i = body.index('<td>Change') or return
  i = body.index('<td', i + 3) or return
  j = body.index("</td", i) or return
  change = strip_html(body[i...j])
  #p change

  i = body.index('<td>&#37;Change') or return
  i = body.index('<td', i + 3) or return
  j = body.index("</td", i) or return
  changepc = "(#{strip_html(body[i...j])}%)"
  #p changepc

  i = body.index(/<td>Last (?:Trade|Update)/) or return
  i = body.index('<td', i + 3) or return
  j = body.index('</td', i) or return
  time = strip_html(body[i...j])
  #p time

  "#{company} #{price} #{change} #{changepc} #{time}"
end

def handle_command(nick, dest, args)
  return "P\t#{SYNTAX}" if args.length == 0

  body = open("http://mobile.quote.com/mobitransfer.aspx?symbols=#{CGI.escape(args)}&requesttype=quotes").read

  if body =~ %r!<td colspan="3">\s*<b>Quotes</b>! &&
      body =~ %r!accesskey="1"\s+href=['"]?([^'"]+)! # "
    url = $1
    body = open("http://mobile.quote.com/#{strip_html(url)}").read
  end

  if (quote = parse_quote(body))
    "P\t#{quote}"
  else
    "P\terror parsing quote for #{args}"
  end
end

load 'boilerplate.rb'
