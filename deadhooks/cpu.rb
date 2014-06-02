`ps -aw -o '%cpu' -o user -o command | grep -v "^ 0.0" | sort -n | tail -1` =~
  /^\s*(\S+)\s+(\S+)\s+(.*)$/
if $1 == '%CPU'
  reply "Nothing using cpu"
else
  cmd = ($3.length > 50) ? $3[0..50] + '...' : $3
  reply "most cpu: #{$1}%, user #{$2}, #{cmd}"
end
