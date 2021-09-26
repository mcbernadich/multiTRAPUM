#!/bin/bash
#Simply call chopObservations.py
path=$1
step=$2
first_sample=$3
last_sample=$4
beams=$5
index=$6
file_index=$7
echo "Copying files from ${path}"
ln -s $(find $path -name *.fil) .
IFS=' ' read -a files <<< $(ls *.fil)
echo "Chopping the ${file_index}-th parts of ${files[${file_index#0}]}."
python3.6 chopObservations.py ${files[${file_index#0}]} ${file_index} $step $first_sample $last_sample $beams $index
rm *fil