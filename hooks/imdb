#!/usr/bin/env ruby

TYPES = %w(all titles names characters quotes)

def parse_body(body, last_url)
    if body.index('<b>No Matches.</b>')
        "P\t#{args} not found"
        elsif (i = body.index('(Exact Matches)') ||
                   body.index('<b>Popular') ||
               body.index('(Approx Matches)</b>'))
        body.index(/<a href="([^"]+)"[^>]*>([^<]+)/, i) or return
        "P\t\"#{strip_html($2)}\" http://imdb.com#{$1}"
    elsif body.index(%r!<strong class="title">([^<]+)!)
        "P\t\"#{strip_html($1)}\" http://imdb.com#{last_url}"
    end
end

def hget(type, stuff)
    type, stuff = CGI.escape(type), CGI.escape(stuff)
    h = Net::HTTP.start('imdb.com', 80)
    loc = "/find?q=#{stuff}&s=#{type}"
    resp = nil
    loop do
        puts "GETing #{loc}"
        resp = h.get(loc)
        puts "code = #{resp.code}"
        if resp.code == '302'
            loc = URI.parse(resp['location']).path
        else
            break
        end
    end
    [resp.code, loc, resp.body]
end

def handle_command(nick, dest, args)
    begin
        args =~ /(?:(#{TYPES.join('|')})\s+)?(.+)/i
            type, stuff = $1, $2
        type = TYPES[0] unless type
        code, last_url, body = hget(type, stuff)

        if code == '200'
            parse_body(body, last_url) or raise 'barf'
        else
            "P\terror #{code} doing imdb search for #{args}"
        end
    rescue
        "P\tIMDB says: DOES NOT COMPUTE (use a web browser)"
    end
end

load 'boilerplate.rb'
