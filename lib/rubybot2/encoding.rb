def fix_encoding(s)
  buf = ''
  s.each_char {|c| buf << (c.valid_encoding? ? c : '?') }
  buf
end
