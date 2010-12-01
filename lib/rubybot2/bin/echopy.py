#!/usr/bin/python

import sys
sys.path.append("..");
from boilerplate import *

def handle_command(nick, dest, args):
	reply("nick: %s, dest: %s, args: %s" % (nick, dest, args))

main(handle_command)
