reply "reworking to use WA's API, do your own damn math in the meantime"
# def googlecalc(expr)
#   data = {}
#   http_get("http://www.google.com/ig/calculator?hl=en&q=#", expr).
#     scan(/(\w+): "((?:[^"]|\\")*)"/).
#     each {|ary| data[ary.first] = ary.last }

#   result =
#     if data['error'] && data['error'].length > 0 && data['error'] != '0'
#       (data['error'] == '4') ?
#         "THERE ARE FOUR LIGHTS" :
#         "Error: #{data['error']}"
#     else
#       "#{data['lhs']} = #{data['rhs']}"
#     end
#   result.encode("UTF-8").
#     gsub(/\\x([0-9a-fA-F]{2})/) {|m| $1.hex.chr}.
#     gsub(/&#([0-9]{1,7});/) {[$1.to_i].pack('U')}.
#     gsub(/<sup>(-?\d+)<\/sup>/) {"^#{$1}"}
# end

# match_args /\S+/, '<expression>'
# if (result = googlecalc($args))
#   reply result
# else
#   reply "Error calculating #{$args}"
# end
