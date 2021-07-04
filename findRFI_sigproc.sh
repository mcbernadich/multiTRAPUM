#!/bin/bash
#
#-------------------------------------------------------------------------------------------------------------------------#
# Call the "seek" SIGPROC search command at DM=0 cm-3/pc to look for strong RFI signals.
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
ln -s $(find $path -name *.fil) .
# Compute the DM base unit. Every DM trial is a multiple of this base unit.
echo "Scrunching "${name}" at 0 DM."
dedisperse *.fil -i ${name}_multibeam_rfifind.peasoup > ${name}_0dm_time_series.tim
echo "Searching in the time series"
seek ${name}_0dm_time_series.tim -z
echo "Making a list os the stronguest signals"
best ${name}_0dm_time_series.prd
#Remove unnecessary files
rm ${name}_0dm_time_series.bst ${name}_0dm_time_series.fld ${name}_0dm_time_series.top ${name}_0dm_time_series.tim
rm *fil
echo " "