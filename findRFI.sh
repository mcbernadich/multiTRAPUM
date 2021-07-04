#!/bin/bash
#
#-------------------------------------------------------------------------------------------------------------------------#
# Call prepdata at DM=0 cm-3/pc to look for strong RFI signals.
# The DM step is computed as indicated in ().
#-------------------------------------------------------------------------------------------------------------------------#
# Arguments:
# - $1 ({filterbank}): the name of the observation, as in {filterbank}.fil
#-------------------------------------------------------------------------------------------------------------------------#
# Inputs:
# - {filterbank}.fil: the filterbank containing the observation data.
# - "birdies" file in the same directory as this scrip to zap unzanted frequencies from the Fourier domain.
#-------------------------------------------------------------------------------------------------------------------------#
# Outputs:
# - {filterbank}.top, a direct output from the seek sigproc command (columns of DM, P, S/N).
# - {filterbank}.prd, a direct output from the seek sigproc command.
# - {filterbank}_header.txt, containing the result of >> header {filterbank}.fil
#-------------------------------------------------------------------------------------------------------------------------#
# Usage example:
# >> bash findPulsarInterval.sh "../random/folder/observation1"
# This command will make produce a .top and .prd file containing candidates.
#-------------------------------------------------------------------------------------------------------------------------#
# Miquel Colom Bernadich i la mare que el va parir, 20/01/2021
#-------------------------------------------------------------------------------------------------------------------------#
#
# Location of the .fil files.
path=$1
name=$2
ln -s $(find $path -name '*.fil') .
echo "Scrunching "${name}" at 0 DM."
prepdata -ncpus 8 -nobary -o ${name}_0dm_time_series *.fil
realfft ${name}_0dm_time_series ${name}_0dm_time_series.dat
rm *.fil
echo " "