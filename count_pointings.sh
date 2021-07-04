#!/bin/bash
path=$1
i=0
IFS=" " read -a pointings <<< $(echo $(ls ${path}))
for pointing in ${pointings[@]}; do
    echo $i
    echo ${path}/${pointing}: $(ls ${path}/${pointing} | wc -l)
    echo $(ls ${path}/${pointing}/cfbf00000)
    i=$[${i}+1]
done
