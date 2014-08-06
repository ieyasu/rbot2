m = match_args(/(\d+)d(\d+)(?:\s*\+\s*(\d+))?/,
      "<number of dice>d<faces>[+offset] example: 3d6")
ndice, faces, offset = m[1].to_i, m[2].to_i, m[3].to_i

exit_reply "need at least 1 dice!" unless ndice > 0
exit_reply "need at least 1 face!" unless faces > 0
exit_reply "cannot have more than 10 dice!" unless ndice <= 10

rolls = []
ndice.times { rolls << rand(faces) + 1 }
sum = rolls.reduce(:+)

msg = rolls.join(' ')
msg += " : #{sum}" if ndice > 1
msg += " + #{offset} = #{sum + offset}" if offset > 0
reply msg
