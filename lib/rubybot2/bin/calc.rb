#!/usr/bin/env ruby

SYNTAX = 'Usage: !calc <expression>'

def googlecalc(expr)
  data = {}
  open("http://www.google.com/ig/calculator?hl=en&q=#{CGI.escape(expr)}").read.
    scan(/(\w+): "((?:[^"]|\\")*)"/).
    each {|ary| data[ary.first] = ary.last }

  result =
    if data['error'] && data['error'].length > 0 && data['error'] != '0'
      "Error: #{data['error']}"
    else
      "#{data['lhs']} = #{data['rhs']}"
    end
  strip_html(result.gsub(/\\x([0-9a-fA-F]{2})/) {|m| $1.hex.chr})
end

def handle_command(nick, dest, args)
  return "P\t#{SYNTAX}" unless args.length > 0

  if (result = googlecalc(args))
    "P\t#{result}"
  else
    "P\tError calculating #{args}"
  end
end

load 'boilerplate.rb'
