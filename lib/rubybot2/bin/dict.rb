#!/usr/bin/env ruby

MAX_OUTPUT_SIZE = 1000
LINE_SIZE = 480

def parse_definitions(body)
  i = body.index('Definitions of <b>') or return
  ary = []
  size = 0
  while (i = body.index('<li>', i))
    i += 4
    j = body.index('<br>', i) or break
    definition = strip_html(body[i...j])
    size += definition.length
    break if size > MAX_OUTPUT_SIZE && ary.length > 0
    ary << definition
    i = j
  end
  ary
end

# put as many definitions on one line as possible, as governed by the protocol
def format_reply(ary)
  reply = ''
  line_size = LINE_SIZE
  defnum = 1
  ary.each do |definition|
    if line_size > 0 && line_size + definition.length > LINE_SIZE
      reply = reply[0..-3] if reply[-2..-1] == ';  '
      reply << "\nP\t"
      line_size = 0
    end
    s = "#{defnum}. #{definition}  "
    line_size += s.length
    reply << s
    defnum += 1
  end
  reply[1..-3]
end

def google_suggestions(args)
  body = open("http://www.google.com/search?hl=en&q=#{CGI.escape(args)}").read
  i = body.index('Did you mean:') or return
  i = body.index(/<a[^>]*>/, i) or return
  i += $~[0].length
  j = body.index('</a>', i) or return
  strip_html(body[i...j])
end

def handle_command(nick, dest, args)
  return "P\tUsage: !dict <word>" unless args.length > 0

  body = open("http://www.google.com/search?hl=en&q=define:#{CGI.escape(args)}").read
  

  if (ary = parse_definitions(body))
    format_reply(ary)
  else
    repl = "P\t#{args} not found"
    sug = google_suggestions(args)
    repl << "; Suggestions: #{sug}" if sug
    repl
  end
end

load 'boilerplate.rb'
