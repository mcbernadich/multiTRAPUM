#!/bin/bash
#
# Just get the filterbak files, scruch them to a time series, and then perform both the fourier transform and de-reddening.
# Location of the .fil files.
path=$1
# Name That is given to the resulting file.
name=$2
# Copy the data here.
ln -s $(find $path -name '*.fil') .
echo "Scrunching "${name}" at 0 DM."
# Make a 0dm time series.
prepdata -ncpus 8 -nobary -o ${name}_0dm_time_series *.fil
# Fourier transform the data.
realfft ${name}_0dm_time_series.dat
# De-redden.
rednoise ${name}_0dm_time_series.fft
rm *.fil
echo " "