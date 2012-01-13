#!/usr/bin/env ruby

SYNTAX = 'Usage: !calc <expression>'

def comify(str)
  str.gsub("\240", ',')
end

def googlecalc(expr)
  data = {}
  open("http://www.google.com/ig/calculator?hl=en&q=#{CGI.escape(expr)}").read.
    force_encoding("ASCII-8BIT").
    scan(/(\w+): "((?:[^"]|\\")*)"/).
    each {|ary| data[ary.first] = ary.last }

  result =
    if data['error'] && data['error'].length > 0 && data['error'] != '0'
      (data['error'] == '4') ?
        "THERE ARE FOUR LIGHTS" :
        "Error: #{data['error']}"
    else
      "#{data['lhs']} = #{data['rhs']}"
    end
  result = comify result.gsub(/\\x([0-9a-fA-F]{2})/) {|m| $1.hex.chr}.
    gsub(/&#([0-9]{1,7});/) {[$1.to_i].pack('U')}.
    gsub(/<sup>(-?\d+)<\/sup>/) {"^#{$1}"}
  result.encode("UTF-8")
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
