m = match_args(/(\S+)\s*(.+)/, '<admin-pass> <raw irc command>')
pass, irc_command = m[1], m[2]

if pass == $rbconfig['admin-passwd']
  priv_reply("sending raw irc message '#{irc_command}'")
  $rep.raw(irc_command)
else
  priv_reply('admin password does not match')
end
