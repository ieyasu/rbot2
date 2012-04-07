require 'net/http'
require 'cgi'
require 'open-uri'
require 'uri'
require 'rubybot2/encoding'
require 'nokogiri'

module Web
    HTML_ENTITIES = {
        'quot'   => '"',
        'amp'    => '&',
        'lt'     => '<',
        'gt'     => '>',
        'nbsp'   => ' ',
        '#39'    => "'",
        '#8217'  => "'",
        '#176'   => '',
        'deg'    => "\u00b0"
    }

    def replace_html_entities(html)
        html.gsub(/&([^;]*);/) do |m|
            if (c = HTML_ENTITIES[$1])
                c
            elsif $1[0,1] == '#'
                Integer($1[1..-1]).chr rescue ''
            else
                ''
            end
        end
    end

    def strip_html(html)
        text = html.gsub(/<p>(.+)<\/p>/, "\\1\n").
            gsub(/<!--(?:[^-]|-[^-])+-->/, '').
            gsub(%r!</?\w*(?:\s+[\w-]+(?:\s*=\s*(?:'[^']*'|"[^"]*"|[^'"> ]+))?)*\s*/?>!m, ' ') #"
        replace_html_entities(text).gsub(/\s+/, ' ').strip.squeeze(' ')
    end

    def http_get(url, *params)
      u = url.gsub('#') {|m| CGI.escape params.shift.to_s}
      s = nil
      open(u, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |fin|
        s = fix_encoding(fin)
      end
      s
    end

    alias :read_url :http_get

    def noko_get(url, *params)
      Nokogiri::HTML(http_get(url, *params))
    end

    def http_post(url, data, headers = {})
        resp = Net::HTTP.post_form(URI.parse(url), headers)
        [resp.code, resp.code == '200' ? resp.body : nil]
    end
end
