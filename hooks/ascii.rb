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

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" unless args && args.length > 0

    resp = ''
    begin
        i = Integer(args) # try as integer
        raise 'too big' if i > 127
        resp = "P\tASCII char of #{i} -> " <<
            if i < ASCII_CONTROL.length
                ASCII_CONTROL[i]
            elsif i < 127
                i.chr
            else
                '(DEL)'
            end
        resp << "\n"
    rescue Exception
        # not an integer
    end
    s = args[0,1] # treat as a string
    i = s[0]
    resp << sprintf("P\tASCII value of #{s} -> %i (0x%x  %08bB  %o Oct)", i, i, i, i)
end

load 'boilerplate.rb'
