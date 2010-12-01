#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'

SYNTAX = 'Usage: !roads []'

BASE_URL = URI.parse('http://www.cotrip.org/rWeather/')

class Array
    def /(n)
        raise ArgumentError, "Not evenly divisible by #{n}" if length % n != 0
        ary = []
        i = 0
        while i < length
            ary << self[i...i + n]
            i += n
        end
        ary
    end
end

def parse_conditions(body, arg)
    ary = (body/"td[@class='contentRoad']").map { |e| e.children.first } / 4
    ary = ary.map do |a|
        s = a[0..2].map { |e| e.content.strip }.join(' ')
        if a.last.respond_to?(:stag) && a.last.stag.name == 'a'
            s << " #{BASE_URL.merge(a.last['href'])}"
        end
        s
    end
    arg = 'I-25 (?:Denver|Ft.\sCollins|Colorado Springs)' if arg == ''
    results = ary.grep(Regexp.new(arg, Regexp::IGNORECASE))
    if results.length > 6
        results = results[0...5] << "#{results.length - 5} more..."
    end
    if results.length == 0
        "couldn't find any conditions for #{arg}"
    else
        results.join(' | ')
    end
end

def handle_command(nick, dest, args)
    body = Hpricot(open("http://www.cotrip.org/atis/web.Travel_ConditionsMarshal?mode=html&Travel_Conditions=0"))
    if body
        if (conds = parse_conditions(body, args))
            "P\t#{conds}"
        else
            "P\terror parsing road conditions for #{args}"
        end
    else
        "P\terror accessing road conditions web page"
    end
end

load 'boilerplate.rb'
