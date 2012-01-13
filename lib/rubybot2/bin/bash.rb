#!/usr/bin/env ruby

%w(rubygems nokogiri open-uri cgi).each {|lib| require lib}

BASH_URL = 'http://bash.org/?random'
MAX_LINES = 3
CORRECTIONS = {
  /<br\s?\/>/ => '',
}

def put(str)
  "P\t#{str}"
end

def handle_command(nick, dest, args)
  doc = Nokogiri::HTML(open(BASH_URL).read)
  quote = (doc/'p.qt')
  if quote.empty?
    put "no quotes found :("
  else
    quote = quote.first.inner_html
    CORRECTIONS.each do |regex, replacement|
      quote.gsub! regex, replacement
    end
    quote = CGI.unescapeHTML(quote)
    quote = quote.split(/\r\n/).compact
    quote_id = (doc/'p.quote/a').first['href']
    if quote.size > MAX_LINES
      quote = quote[0..(MAX_LINES-2)] 
      quote << "[...] more at http://bash.org/#{quote_id}"
    end

    quote.map {|q| put q}.join("\n")
  end
rescue Exception => e
  "P\terror: #{e}"
end

load 'boilerplate.rb' 
