import sys

def reply(text):
	global dest
	while text and len(text) > 1:
		if(len(text) > 420):
			i = text.rindex(' ', 420)
		else:
			i = len(text)
		r = text[:i]
		if ( r[len(r)-1] == ","):
			r = r + '\n'
		text = text[i + 1:]
		print "PRIVMSG %s :%s" % (dest, r)

def main(callback):
	global dest
	if(sys.argv[2][0] == '#'):
		dest = sys.argv[2]
	else:
		dest = sys.argv[1]
	callback(sys.argv[1], sys.argv[2], sys.argv[3]) # nick, dest, args
