msg_hooks = $rbconfig['msg-commands']
list = Dir['hooks/*'].to_a.map do |file|
  hook = File.basename(file, '.rb')
  hook << '*' if msg_hooks.member?(hook)
  hook
end.sort.join(', ')
priv_reply("Hooks: " + list)
priv_reply('* = /msg only')
