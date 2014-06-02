ff = noko_get('http://kaction.com/badfanfiction/')
s = ff.at('div.shadowbox-inner').inner_text
reply s[0..s.index('plot device!') + 12].gsub("\n", ' ').gsub('  ', ' ')
