require 'net/http'
require 'cgi'
require 'open-uri'
require 'uri'

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
        'deg'    => "\260"
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
        text = html.gsub(/<p>(.+)<\/p>/, "\1\n").
            gsub(/<!--(?:[^-]|-[^-])+-->/, '').
            gsub(%r!</?\w*(?:\s+[\w-]+(?:\s*=\s*(?:'[^']*'|"[^"]*"|[^'"> ]+))?)*\s*/?>!m, ' ') #"
        replace_html_entities(text).gsub(/\s+/, ' ').strip.squeeze(' ')
    end

    def http_post(url, data, headers = {})
        resp = Net::HTTP.post_form(URI.parse(url), headers)
        [resp.code, resp.code == '200' ? resp.body : nil]
    end
end
