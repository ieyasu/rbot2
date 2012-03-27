import C_LookerUpper
import time
import sys

if len(sys.argv) < 2:
	print "Usage: " + sys.argv[0] + " [word]"
	sys.exit(1)

lu = C_LookerUpper.LookerUpper(sys.argv[1])
lu.start()
timeoutIn = 15
while not lu.lookupsComplete:
    time.sleep(1)
    timeoutIn = timeoutIn - 1
    if timeoutIn <= 0:
        print "Time out :("

print "*****************"
print ""
print lu.lookupResults
print ""
print "MW Results: "
print lu.lookupResults['mw']['definition']
