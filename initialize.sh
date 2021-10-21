#!/bin/bash
#Initialize the environment where you will run the masks from.
#pointings_path: path to the main location of the pointings.
path=$1
#dir: name of directory that will be created. It will also work if you give an existend directory.
dir=$2
#Create the directory.
mkdir $dir
#Copy the necessry files into the folder.
cp chopCall.sh $dir
cp deRed.sh $dir
cp chopObservations.py $dir
cp computeMasks.py $dir
cp readBirdies.py $dir
cp rfifind_stats_noplot.py $dir
cp findUTC.py $dir
cp initialize.sh $dir
cp multiBeam.sh $dir
cp readHeader.sh $dir
cp writeStart.py $dir
cp getout_rfifind.py $dir
cp translate.py $dir
cp fourier0dm.sh $dir
cp zapFourier.py $dir
#Write the arguments file.
echo "# general parameters" > ${dir}/arguments.txt
echo "path:" >> ${dir}/arguments.txt
echo "pointing_list:" >> ${dir}/arguments.txt
echo "rfifind_beams:" >> ${dir}/arguments.txt
echo "birdies_beams:" >> ${dir}/arguments.txt
echo "chop_samples:" >> ${dir}/arguments.txt
echo "# rfifind parameters" >> ${dir}/arguments.txt
echo "ncpus:" >> ${dir}/arguments.txt
echo "time:" >> ${dir}/arguments.txt
echo "timesig:" >> ${dir}/arguments.txt
echo "freqsig:" >> ${dir}/arguments.txt
echo "chanfrac:" >> ${dir}/arguments.txt
echo "intfrac:" >> ${dir}/arguments.txt