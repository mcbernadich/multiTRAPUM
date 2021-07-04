#!/usr/bin/python
import numpy as np
import sys
import matplotlib
from matplotlib import colors, ticker, cm
import  matplotlib.pyplot as plt
fil_filenm   = sys.argv[1]
output = sys.argv[2]
x = open(fil_filenm)
#reading some important fields from the .mask file
time_sig, freq_sig, MJD, dtint, lofreq, df = np.fromfile(x, dtype=np.float64, count=6)
nchan, nint, ptsperint = np.fromfile(x, dtype=np.int32, count=3)
freqs = np.arange(nchan)*df + lofreq
times = np.arange(nint)*dtint
MJDs = times/86400.0 + MJD
#reading the number of FULL channel zapped 
nzap = np.fromfile(x, dtype=np.int32, count=1)[0]
print "Total number of channel zapped", nzap
print "percentage of channel zapped", 100*nzap/float(nchan),"%"
#read nzap amount of int32 to get which channel is being zap 
mask_zap_chans = np.fromfile(x, dtype=np.int32, count=nzap)
mask_values = np.ones(nchan, dtype=int)
for i in range(len(mask_zap_chans)):
    mask_values[mask_zap_chans[i]] = 0
print "Channel zapped", mask_zap_chans
np.savetxt(str(output)+'.badchan', mask_zap_chans,fmt='%i', delimiter=',')
np.savetxt(str(output)+'.badchan_peasoup', mask_values,fmt='%i', delimiter=',')
