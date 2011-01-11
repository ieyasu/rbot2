import os
import urllib2
import urllib
import re
from threading import Thread
import traceback
import sys

from htmlentitydefs import name2codepoint as n2cp
import re

class LookerUpper(Thread):
    word = ""
    lookupResults = {}
    lookupsComplete = False
    definition = ""

    def __init__(self, word):
        Thread.__init__(self)
        self.word = word.lower()
        self.lookupResults = {
            "wordnet": { "pending" : True, "status": "ERROR" },
            "mw":{ "pending" : True, "status": "ERROR" },
            "scrabble":{ "pending" : True, "status": "ERROR" },
            "web1913":{ "pending" : True, "status": "ERROR" }
        }
        self.definition = ""
        self.lookupsComplete = False


    def toString(self):
        try:
            str = ""
            for key, res in self.lookupResults.iteritems():
                color = "{GRAY}"
                if res['pending'] == False:
                    if res['found'] == True:
                        if res['status'] == "WARNING":
                            color = "{YELLOW}"
                        if res['status'] == "GOOD":
                            color = "{GREEN}"
                    else:
                        color = "{RED}"
                str = str + color + key + " "

            return str[:-1] + "{NORMAL}"
        except Exception:
            traceback.print_tb(sys.exc_info()[2])
            return ">_<"

    def run(self):
        multSpaces = re.compile('\s+')

        try:
            #
            # scrabble
            #
            # - This is read from a local file
            wordInfo = {
                "found" : False,
                "definition" : "",
                "pending" : False,
                "status": "BAD"
            }
            file = open("db/scrabbledict.txt", "r")
            for line in file:
                line = line.strip()
                parts = line.split(":")
                if parts[0].strip().lower() == self.word:
                    wordInfo['found'] = True
                    wordInfo['status'] = "GOOD"
                    wordInfo['definition'] = parts[1].strip()
                    break

            self.lookupResults['scrabble'] = wordInfo


            #
            # wordnet (dict.org)
            #
            args = {
                        "Query": self.word,
                        "Strategy": "*",
                        "Database": "wn",
                        "Form":"Dict1"
            }
            baseRequest = "http://www.dict.org/bin/Dict"
            response_h = urllib2.urlopen(baseRequest, urllib.urlencode(args))
            response = ""
            for line in response_h:
                response = response + line

            #print response

            try:
                wordInfo = {
                    "found" : False,
                    "definition" : "",
                    "pending" : False,
                    "status": "ERROR"
                }

                # Check if the word wasn't found
                if response.find("No definitions found") == -1:
                    pattern = re.compile('<pre>.*?</pre>', re.DOTALL)
                    matches = pattern.findall(response)

                    defin = matches[2]
                    defin = self.strip_tags(defin)
                    defin = defin.strip()
                    wordInfo['found'] = True
                    wordInfo['definition'] = defin
                    wordInfo['status'] = "GOOD"

                    if defin.find("[Obs.]") != -1:
                        wordInfo['status'] = "WARNING"
                else:
                    wordInfo['status'] = "BAD"

                wordInfo['definition'] = multSpaces.sub(' ', wordInfo['definition'])
                self.lookupResults['wordnet'] = wordInfo
            except Exception:
                print "wordnet failed"
                #traceback.print_tb(sys.exc_info()[2])

            #
            # webster's 1913 (dict.org)
            #
            args = {
                        "Query": self.word,
                        "Strategy": "*",
                        "Database": "web1913",
                        "Form":"Dict1"
            }
            baseRequest = "http://www.dict.org/bin/Dict"
            response_h = urllib2.urlopen(baseRequest, urllib.urlencode(args))
            response = ""
            for line in response_h:
                response = response + line

            #print response

            try:
                wordInfo = {
                    "found" : False,
                    "definition" : "",
                    "pending" : False,
                    "status": "ERROR"
                }

                # Check if the word wasn't found
                if response.find("No definitions found") == -1:
                    pattern = re.compile('<pre>.*?</pre>', re.DOTALL)
                    matches = pattern.findall(response)

                    defin = matches[2]
                    defin = self.strip_tags(defin)
                    defin = defin.strip()
                    wordInfo['found'] = True
                    wordInfo['definition'] = defin
                    wordInfo['status'] = "GOOD"

                    if defin.find("[Obs.]") != -1:
                        wordInfo['status'] = "WARNING"
                else:
                    wordInfo['status'] = "BAD"

                wordInfo['definition'] = multSpaces.sub(' ', wordInfo['definition'])
                self.lookupResults['web1913'] = wordInfo
            except Exception:
                print "websters 1913 failed"
                #traceback.print_tb(sys.exc_info()[2])


            #
            # m-w.com
            #
            try:
                baseRequest = "http://www.merriam-webster.com/dictionary/" + urllib.quote(self.word)
                response_h = urllib2.urlopen(baseRequest)
                response = ""
                for line in response_h:
                    response = response + line
                wordInfo = {
                    "found" : False,
                    "definition" : "",
                    "pending" : False,
                    "status": "ERROR"
                }

                # Check if the word wasn't found
                if response.find("The word you've entered isn't in the dictionary") == -1:
                    wordInfo['found'] = True
                    try:
			# sometimes they are divs with class 'scnt'
                        pattern = re.compile('<div class=\"scnt\">.*?</div>', re.DOTALL)
                        matches = pattern.findall(response)

                        # and sometimes spans with class ssens
                        if len(matches) == 0:
                                pattern = re.compile('<div class=\"scnt\">.*?</div>', re.DOTALL)
                                matches = pattern.findall(response)

                        if len(matches) > 0:
			    wordInfo['status'] = "GOOD"
                            defin = matches[0]
                            defin = self.strip_tags(defin)
                            defin = defin.strip()
                            defin = defin.replace("\n\n", "\n")
			    # Clean up first part of the definition
			    if defin.startswith("a   : "):
				defin = defin[6:]
                            wordInfo['definition'] = self.decode_htmlentities(defin)

                        # Check to see if we were redirected to something weird
                        pattern = re.compile('<span class="variant">.*?</span>', re.DOTALL)
                        matches = pattern.findall(response)
                        if len(matches) > 0:
                            variant = matches[0]
                            variant = variant.replace("<sup>1</sup>", "")
                            variant = self.strip_tags(variant).strip()
                            variant = variant.replace("&#183;", "")
                            print "Variant: ", variant

                            if variant != self.word:
                                wordInfo['definition'] = "{YELLOW}Redirected to: " + variant + "{NORMAL} - " + wordInfo['definition']
                                wordInfo['status'] = "WARNING"


                        wordInfo['definition'] = wordInfo['definition'].replace("\u2014", "--")
                    except Exception:
                        print "-- MW parsing failure"
                        traceback.print_tb(sys.exc_info()[2])

                    if response.find("can be found at Merriam-WebsterUnabridged.com") != -1:
                        wordInfo['definition'] = "<In MW Unabridged>"
                        wordInfo['status'] = "WARNING"
                else:
                    wordInfo['status'] = "BAD"

                wordInfo['definition'] = multSpaces.sub(' ', wordInfo['definition'])
                self.lookupResults['mw'] = wordInfo
            except Exception:
                print "mw failed"
                #traceback.print_tb(sys.exc_info()[2])


        except Exception, e:
            print "Exception :("
            traceback.print_tb(sys.exc_info()[2])

        #print "Finished looking up word:", self.word, self.lookupResults

        self.definition = "<None Found>"
        if self.lookupResults['mw']['pending'] == False and self.lookupResults['mw']['found']: self.definition = self.lookupResults['mw']['definition']
        if self.lookupResults['wordnet']['pending'] == False and self.lookupResults['wordnet']['found']: self.definition = self.lookupResults['wordnet']['definition']
        if self.lookupResults['web1913']['pending'] == False and self.lookupResults['web1913']['found']: self.definition = self.lookupResults['web1913']['definition']
        if self.lookupResults['scrabble']['found']: self.definition = self.lookupResults['scrabble']['definition']

        self.lookupsComplete = True


    def strip_tags(self, value):
        "Return the given HTML with all tags stripped."
        return re.sub(r'<[^>]*?>', '', value)


    def substitute_entity(self, match):
        ent = match.group(2)
        if match.group(1) == "#":
            return unichr(int(ent))
        else:
            cp = n2cp.get(ent)

            if cp:
                return unichr(cp)
            else:
                return match.group()

    def decode_htmlentities(self, string):
        try:
            entity_re = re.compile("&(#?)(\d{1,5}|\w{1,8});")
            return entity_re.subn(self.substitute_entity, string)[0]
        except:
            print ":( Failed to decode htmlentities"
            return string
