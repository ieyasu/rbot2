#!/usr/bin/env ruby

SYNTAX = 'Usage: !froogle <product>'

def parse_product(body, i)
    i = body.index('<td width=25% class=bo', i) or return

    i = body.index('<a', i) or return
    i += 3

    i = body.index(/(<a[^>]+>)/, i) or return
    i += $1.length
    j = body.index('</a>', i) or return
    product = strip_html(body[i...j])

    i = body.index('$', j) or return
    j = body.index('</font>', i) or return
    price_loc = strip_html(body[i...j])

    [product << ' ' << price_loc, j]
end

def parse_products(body)
    prods = ''
    i = 0
    3.times {
        p, i = parse_product(body, i)
        return unless p
        prods << ' || ' << p
    }
    prods[4..-1]
end

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" if args.length == 0

    body = read_url("http://froogle.google.com/froogle?q=#{CGI.escape(args)}&hl=en&show=li&lnk=showgrid")
    res = parse_products(body)
     res ? "P\t#{res}" : "P\t#{args} not found"
end

load 'boilerplate.rb'
