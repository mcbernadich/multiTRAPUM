import sys
import numpy as np
import glob
# This code looks for masks of a particular name and counts the amount of masked channels.
# sys.argv[1] should be a key string for the files you are looking for.

def count_channels(mask):
    read_file=open(mask,"r")
    chans=read_file.readline()
    chans=chans.split(",")
    total=0
    for pair in chans:
        hi_lo=pair.split(":")
        if len(hi_lo)==2:
            total=total+int(hi_lo[1])-int(hi_lo[0])+1
        else:
            total=total+1
    name=np.array(mask.split("_"))
    pointing_name_ar=np.flip(np.flip(name,0)[4:],0)
    read_file.close()
    pointing_name_str=""
    for element in pointing_name_ar:
        pointing_name_ar=pointing_name_str+element+"_"
    read_file=open(pointing_name_str+"multibeam_birdies_logs.txt","r")
    line=read_file.readline()
    line=read_file.readline()
    line=read_file.readline()
    line=read_file.readline()
    line=read_file.readline()
    line=line.split(" ")[0]
    print(pointing+": "+str(100*total/2048)+"% frequency channels, "+line+" Fourier bins.")
    return total

files = sorted(glob.glob(str(sys.argv[1])))
for i in files:
    a=count_channels(i)
