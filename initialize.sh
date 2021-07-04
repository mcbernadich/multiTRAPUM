#!/bin/bash
#Give it the directory and it fill create a bunch of folders with the scripts in them.
path=$1
IFS='/' read -a path_a <<< $path
IFS=' ' read -a subdirectories <<< "1 2 3 4"
mkdir ${path_a[-1]}
for subdirectory in ${subdirectories[@]}; do
mkdir ${path_a[-1]}/${subdirectory}
	cp chopCall.sh ${path_a[-1]}/${subdirectory}
	cp chopObservations.py ${path_a[-1]}/${subdirectory}
	cp computeMasks.py ${path_a[-1]}/${subdirectory}
	cp readBirdies.py ${path_a[-1]}/${subdirectory}
	cp rfifind_stats_noplot.py ${path_a[-1]}/${subdirectory}
	cp findUTC.py ${path_a[-1]}/${subdirectory}
	cp initialize.sh ${path_a[-1]}/${subdirectory}
	cp multiBeam.sh ${path_a[-1]}/${subdirectory}
	cp readHeader.sh ${path_a[-1]}/${subdirectory}
	cp writeStart.py ${path_a[-1]}/${subdirectory}
	cp getout_rfifind.py ${path_a[-1]}/${subdirectory}
	cp translate.py ${path_a[-1]}/${subdirectory}
	cp fourier0dm.sh ${path_a[-1]}/${subdirectory}
	cp zapFourier.py ${path_a[-1]}/${subdirectory}
	echo "#!/bin/bash" > ${path_a[-1]}/${subdirectory}/execute.sh
	echo "bash multiBeam.sh "${path}" "$[${subdirectory}*10-10]","$[${subdirectory}*10-1]" > logs.txt" >> ${path_a[-1]}/${subdirectory}/execute.sh
done
echo "#!/bin/bash" > ${path_a[-1]}/join.sh
echo "cat 1/zappingList.sql 2/zappingList.sql 3/zappingList.sql 4/zappingList.sql > zappingList.sql" >> ${path_a[-1]}/join.sh
echo "cat 1/fractionList.ascii 2/fractionList.ascii 3/fractionList.ascii 4/fractionList.ascii > fractionList.ascii" >> ${path_a[-1]}/join.sh
