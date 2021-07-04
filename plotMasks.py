import sys
import glob
import matplotlib.pyplot as plt
# sys.argv[1] should be a key string for the files you are looking for.

def parse_mask(fname):
    with open(fname, "r") as f:
        mask = f.readline()
        return [list(map(float, i.split(":"))) for i in mask.split(",")]

files = sorted(glob.glob(str(sys.argv[1])))
masks = [parse_mask(i) for i in files]

plt.figure(figsize=[1,1])
ii = 0
for mask in masks:
    for lo, hi in mask:
    	plt.fill_between([lo, hi], ii, ii+1, color="b")
    ii+=1
plt.xlabel("Frequency MHz")
plt.ylabel("Significance")
plt.show()