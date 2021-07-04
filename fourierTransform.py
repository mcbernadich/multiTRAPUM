# Compute the power of the fourier transform of a time series.
# In: 
#    - the ascii file with the dedispersed time series.
# It should have two columns: the first one being time and the second one intensity.
# Out: print the Fourier power spectrum, that's it.
# Produced files: {name}_results.ascii (dm,period,fourier power,i)
#                 {name}_{i}_fourier.ascii (frequency,fourier)
import numpy as np
import sys
filename=sys.argv[1]
# -------------------------------------------------------- #
# The script begins.                                       #
# -------------------------------------------------------- #
# Read the file and transpose it. Every column is now an array.
print("Reading the time-series.")
time_series=np.loadtxt(sys.argv[1]).T
# Fourier transform the second array.
print("Fourier transforming the time-series.")
fourier_series=np.square(np.absolute(np.fft.fft(time_series[1])))
# Get the amount of time bins. Store them in fouruer_series.
series_size=np.size(time_series[0])
# Build an array with the frequency values. It is the coordinate axis of the fourier transform.
frequency_series=np.arange(start=1,stop=series_size+1)/(time_series[0,1]*series_size)
# Store the fourier spectrum in the {name}_{i}_fourier.asci file.
print("Storing the Fourier transform.")
fourier_file=filename.split(".")
np.savetxt("{}_fourier.ascii".format(fourier_file[0]),np.array([frequency_series[0:int(series_size/2)],fourier_series[0:int(series_size/2)]]).T,header="frequency(Hz) power")
