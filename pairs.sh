#!/usr/bin/python
import json
import sys
usage = "pairs.py tokens.json"
if len(sys.argv)!=2:
   print usage
   sys.exit(1)
tokens = open(sys.argv[-1],"r").read()
tokens = json.loads(tokens)
print 'coins = [',
for token in tokens:
   print '"'+token['symbol']+'",',
print "]"
