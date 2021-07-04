#!/bin/bash
#Simply copy the files from a directory and run header on them.
path=$1
file_index=$2
echo "Copying files from ${path}"
ln -s $(find ${path} -name *.fil) .
IFS=' ' read -a files <<< $(ls *.fil)
echo "Reading header data from ${files[${file_index}]}."
header ${files[${file_index}]} >> headers.txt
rm *.fil