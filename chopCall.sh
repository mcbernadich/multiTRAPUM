#!/bin/bash
#Simply call chopObservations.py on the reddened files.
path=$1
step=$2
first_sample=$3
last_sample=$4
beams=$5
index=$6
file_index=$7
echo "Taking the de-reddened version of the file in ${path}"
file=$(ls *_01.fil)
echo "Chopping the ${file_index}-th half of ${files[${file_index#0}]}."
python3.6 chopObservations.py $file $file_index $step $first_sample $last_sample $beams $index
rm *.fil