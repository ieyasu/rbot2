def fix_encoding(s)
  s = s.read unless String === s
  s.valid_encoding? ? s : s.force_encoding("ISO-8859-1").encode("UTF-8")
end
