#!/usr/bin/env ruby

%w(rubygems hpricot open-uri cgi).each {|lib| require lib}

MAX_CHARS = 700
TRUNCATE = 400 # cut off this many if it's too long

def handle_command(nick, dest, args)

  hug_url = 'http://confessions.grouphug.us/'
  if args.empty?
    hug_url << 'random' # get a random one
  else
    hug_url << "confessions/#{args.split.first}"
  end

	doc = Hpricot(open(hug_url))
  #con = (doc/'td.conf-text/p')
  con = (doc/'div.node-confession div.content')
  if con.empty?
    "P\tno confession found :("
  else
    con = (con.first/"p").map {|p| p.inner_html}.join(" ")
    con.gsub!(/<\/?[^>]*>/, "") # strip html tags
    con.gsub!(/\s+/,' ')        # clean up excess whitespace
    con.gsub!(/&\w+;/,' ')      # strip html entities
    con.gsub!(/&#8217;/,"'")
    con.gsub!(/&#\d{4}/, '')
    
    con = "no confession found :(" if con.strip.empty?

    #con_id = (doc/'td.conf-id/h4')
    if (con_id = (doc/'div.node-confession h2.title')) && !con_id.empty?
      if (con_id/'a').empty?
        con_id = con_id.inner_html.strip
      else
        con_id = (con_id/'a').first.inner_html
      end
    elsif con_id = (doc/'h1.title')
      con_id = con_id.inner_html
      else
      con_id = "geh fail!"
    end

    if con.size > MAX_CHARS
      con = con[0..(MAX_CHARS-TRUNCATE-2)]
      con.gsub!(/\w+\s*$/,"[...] http://grouphug.us/confessions/#{con_id}")
    end
    "P\t<#{con_id}> #{con}"
  end
rescue Exception => e
  "P\terror: #{e}"
end

require 'boilerplate' 
