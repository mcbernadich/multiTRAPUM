import sys
import json
#Simply find the starting UTC of the observation from the metadata
#arg1 is the name and location of the metafile.
#arg2 is what is to be read from the metafile.
with open(sys.argv[1],"r") as f:
    meta=json.load(f)
thing=str(meta[sys.argv[2]].split(",")[0])
thing=thing.replace("/","-")
print(thing)