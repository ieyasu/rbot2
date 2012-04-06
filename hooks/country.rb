match_args /[a-zA-Z.]/, '<tld> | <country name>'

MAX_RESULTS = 8

$args = ".#{$args}" if $args =~ /^[a-zA-Z]{2,3}$/
$args = "'#{$args.gsub(/\\*\./, "\\\\.")}'"
exit_reply "tld or country name too short" if $args.length < 3

result=`grep -i #{$args} db/tld.txt`
if result.length > 0
  ary = result.split(/\r?\n/).map {|l| l.sub(/ /, ' - ')}
  ary = ary[0...MAX_RESULTS] if ary.length > MAX_RESULTS
  reply ary.join(", ")
else
  reply "#{$args.gsub("\\", '')} not found"
end
