#!/bin/bash                                                                                                                          
#Simply de-redden files with filtools.                                                                                                  
path=$1
file_index=$2
echo "Copying files from ${path}"
ln -s $(find $path -name *.fil) .
IFS=' ' read -a files <<< $(ls *.fil)
IFS='.' read -a name <<< ${files[${file_index#0}]}
echo "De-reddening the ${file_index}-th part of ${files[${file_index#0}]}."
filtool -o ${name[0]} -f ${files[${file_index#0}]}
