#!/usr/bin/python
import sys
sys.path.append("..")
from boilerplate import *
import C_LookerUpper
import time

def getColoredString(str):

	str = str.replace("{BOLD}", "\002")
	str = str.replace("{UNDERLINE}", "\031")
	str = str.replace("{INVERSE}", "\015")

	str = str.replace("{NORM}", "\00315")
	str = str.replace("{NORMAL}", "\00315")
	str = str.replace("{WHITE}", "\0030")
	str = str.replace("{BLACK}", "\0031")
	str = str.replace("{DARKBLUE}", "\0032")
	str = str.replace("{GREEN}", "\0033")
	str = str.replace("{LIGHTRED}", "\0034")
	str = str.replace("{RED}", "\0035")
	str = str.replace("{PURPLE}", "\0036")
	str = str.replace("{LIGHTYELLOW}", "\0037")
	str = str.replace("{YELLOW}", "\0038")
	str = str.replace("{LIGHTGREEN}", "\0039")
	str = str.replace("{TURQOISE}", "\00310")
	str = str.replace("{LIGHTBLUE}", "\003011")
	str = str.replace("{BLUE}", "\00312")
	str = str.replace("{PINK}", "\00313")
	str = str.replace("{GRAY}", "\00314")

	return str

def coloredReply(str):
	reply(getColoredString(str))

def handle_command(nick, dest, arg):
	forceDict = ""
	args = arg.split()
	if(len(args) == 2):
		word = args[0]
		forceDict = args[1]
	elif(len(args) == 1):
		word = args[0]
	else:
		coloredReply("Usage: !d <word> [dictionary]")
		return

	lu = C_LookerUpper.LookerUpper(word)
	lu.start()
	timeoutIn = 15
	while not lu.lookupsComplete:
		time.sleep(1)
		timeoutIn = timeoutIn - 1
		if timeoutIn <= 0:
			coloredReply("Lookup of " + args[1] + " timed out :(")
			coloredReply("{BOLD}[" + lu.toString() + "]{BOLD} " + lu.lookupResults[forceDict]['definition'])
			return

	if forceDict != "":
		# print "Using dict: '" + forceDict + "'" + "(" + str(lu.lookupResults.keys()) + ")"
		if forceDict in lu.lookupResults.keys():
			# print "Looking up in: ", lu.lookupResults[forceDict].keys()
			coloredReply("{BOLD}[" + lu.toString() + "]{BOLD} " + lu.lookupResults[forceDict]['definition'])
		else:
			coloredReply("No dictionary matches '" + forceDict + "'")
	else:
		coloredReply("{BOLD}[" + lu.toString() + "]{BOLD} " + lu.definition)

main(handle_command)
