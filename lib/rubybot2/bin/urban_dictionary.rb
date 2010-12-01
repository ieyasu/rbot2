#!/usr/bin/env ruby

MAX_OUTPUT_SIZE = 1000

def parse_definitions(body)
  return if body.index('</b> is undefined.')
  i = 0
  ary = []
  size = 0
  while (i = body.index("<div class='definition'>", i))
    j = body.index("<div class='example'>", i) ||
      body.index("<div class='greenery'>", i)
    definition =  strip_html(body[i...j])
    size += definition.length
    ary << definition
    break if ary.length > 0 && size > MAX_OUTPUT_SIZE
    i = j
  end
  ary if ary.length > 0
end

# put as many definitions on one line as possible, as governed by the protocol
def format_reply(ary)
  ra = []
  ary.each_with_index {|r, i| ra << "P\t#{i + 1}. #{r}"}
  ra
end

def handle_command(nick, dest, args)
  return "P\tUsage: !dict <word>" unless args.length > 0

  body = open("http://www.urbandictionary.com/define.php?term=#{CGI.escape(args)}").read
  if (ary = parse_definitions(body))
    format_reply(ary)
  else
    "P\terror parsing definition for #{args}"
  end
end

load 'boilerplate.rb'
