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

def to_char(i)
  (i < ASCII_CONTROL.length) ? ASCII_CONTROL[i] : i.chr(Encoding::UTF_8)
end

def show_hex(s, h)
  reply "unicode hex #{s} -> #{to_char h.hex}"
end

def show_oct(s, o)
  reply "unicode oct #{s} -> #{to_char o.oct}"
end

def show_dec(s, d)
  reply "unicode dec #{s} -> #{to_char d.to_i}"
end

def show_chars(s)
  s.each_char.to_a.uniq[0,5].map do |c|
    cp = c.codepoints.first
    os = c.bytes.to_a.map {|b| "\\%03o" % b}.join
    hs = c.bytes.to_a.map {|b| "\\x%X" % b}.join
    if cp >= ASCII_CONTROL.length && cp < 127
      sprintf "unicode %s -> %i  U+%02X  \"%s\"", c, cp, cp, c
    elsif cp <= 0xFFFF
      sprintf "unicode %s -> %i  U+%04X  &#x%04X;  \"\\u%04X\"  \"%s\"  \"%s\"",
        c, cp, cp, cp, cp, os, hs
    else
      sprintf "unicode %s -> %i  U+%08X  &#x%08X;  \"\\U%08X\"  \"%s\"  \"%s\"",
      c, cp, cp, cp, cp, os, hs
    end
  end.each {|m| reply m}
end

match_args /\S+/, '(CHAR|CODEPOINT)'

# many different notations: http://billposer.org/Software/ListOfRepresentations.html
# \u(hex)
# \x(byte)
# \330 # => octal in ruby, python, C, etc.
# 0x99  0245 # => number like in C
# U+FFFF code point notation
# \U(hex*8) => C#
# &#0233; &#x00E9; html
case $args
when /&#(x)?(\h+)/ # html
  $1.nil? ? show_dec($2, $2) : show_hex($2, $2)
when /(?:u\+?|\\u)[\{"'#]?(\h+)[#'"}]?/i # lots of stuff
  show_hex $1, $1
when /((?:\\(?:[xX]\h\h|\d{1,3}))+)/ # ruby
  s = '"' + $1 + '"'
  reply "unicode escape #{s} -> #{eval(s)}"
when /(0x(\h+))/ # C-like hex number
  show_hex $1, $2
when /(0(\d+))/ # C-like octal number
  show_oct $1, $2
when /(\d{2,})/
  show_dec $1, $1
when /^(.)/
  show_chars $args
else
  reply "unsupported unicode syntax '#{$args}'"
end
