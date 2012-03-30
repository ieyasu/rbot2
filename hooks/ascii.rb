#!/usr/bin/env ruby

SYNTAX = 'Usage: !ascii (CHAR|NUMBER)'

ASCII_CONTROL = [
    '(null)',
    '(start of heading)',
    '(start of text)',
    '(end of text)',
    '(end of transmission)',
    '(enquiry)',
    '(acknowledge)',
    '(bell)',
    '(backspace)',
    '(horizontal tab)',
    '(NL line feed, new line)',
    '(vertical tab)',
    '(NP form feed, new page)',
    '(carriage return)',
    '(shift out)',
    '(shift in)',
    '(data link escape)',
    '(device control 1)',
    '(device control 2)',
    '(device control 3)',
    '(device control 4)',
    '(negative acknowledge)',
    '(synchronous idle)',
    '(end of trans. block)',
    '(cancel)',
    '(end of medium)',
    '(substitute)',
    '(escape)',
    '(file separator)',
    '(group separator)',
    '(record separator)',
    '(unit separator)',
    "' '"
   ]

def show_char(args, i)
  if i <= 127
    s =
      if i < ASCII_CONTROL.length
        ASCII_CONTROL[i]
      elsif i < 127
        i.chr
      else
        '(DEL)'
      end
    "P\tASCII char of #{args} -> #{s}"
  else
    "P\t#{i} > 127, try !unicode"
  end
end

def handle_command(nick, dest, args)
  case args
  when /^(0\d+)/
    show_char $1, args.oct
  when /^(0x\h+)/
    show_char $1, args.hex
  when /^(\d{2,})/
    show_char $1, args.to_i
  when /(.+)/
    resp = []
    resp << show_char(args, args.to_i) if args =~ /^\d$/
    args.chars.to_a.uniq[0,5].each do |c|
      i = c.codepoints.first
      resp << sprintf("P\tASCII value of #{c} -> %i (0x%x  %08bB  0%o)", i, i, i, i)
    end
    resp.join("\n")
  else
    "P\t#{SYNTAX}"
  end
end

load 'boilerplate.rb'
