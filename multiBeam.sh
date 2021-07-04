#!/bin/bash
#Get the directory of the pointigns.
path=$1
#Get a range of the pontings that you desire to run through. If it is all of them, just write "all". Otherwise, "first,last", starting from 0.
range=$2
#Collect the pointings
pointings=$(ls ${path})
if [ $range = "all" ]; then
    pointing_list=${pointings}
else
    IFS=',' read -a ra <<< $range
    low=$[${ra[0]}*16+1]
    high=$[${ra[1]}*16+15]
    pointing_list=$(echo ${pointings[@]} | cut -c${low}-${high})
fi
echo ""
echo "|------------------------------------------------------------------------------------|"
echo "|-----Multi-beam channel mask producer, with rfifind and sigpyproc.------------------|"
echo "|-----Using getout_rfifind.py from P. Padmanabh and parts of rfifind_getout----------|"
echo "|-----from V. Balakrishnan and M. Cruces, version 15.10.19 .-------------------------|"
echo "|------------------------------------------------------------------------------------|"
echo ""
echo "Pointings ${pointing_list} found in ${path}"
rm *.chop
rm *.fil
rm headers.txt
rm intervals.ascii
rm zappingList.sql
#Loop over the pointings.
for pointing in ${pointing_list}; do
	name=$(python3 findUTC.py ${path}/${pointing}/apsuse.meta boresight)
	utc_start=$(python3 findUTC.py ${path}/${pointing}/apsuse.meta utc_start)
	echo ""
	echo ""
	echo ""
	echo "|--------------------------------------------------------------------------------------------------|"
	echo "Working on pointing ${path}/${pointing} (${name}), with starting time ${utc_start}"
	echo ""
	echo ""
	echo "Setting up script to run the fourier transforms in the bakground."
	mkdir ${name}_Fourier
	echo "#!/bin/bash" > ${name}_Fourier/birdies_script.sh
	echo "IFS=' ' read -a beams <<< '000 476 025 461'" >> ${name}_Fourier/birdies_script.sh
	echo 'for beam in ${beams[@]}; do' >> ${name}_Fourier/birdies_script.sh
	echo '	singularity exec -B /:/data:ro //beegfs/u/ebarr/singularity_images/fold-tools-2020-11-18-4cca94447feb.simg bash ../fourier0dm.sh /data'${path}'/'${pointing}'/cfbf00${beam} '${name}'_cfbf00${beam} > '${name}'_cfbf00${beam}_logs.txt' >> ${name}_Fourier/birdies_script.sh
	echo "done" >> ${name}_Fourier/birdies_script.sh
	echo 'Moving to '${name}'_Fourier .'
	cd ${name}_Fourier
	echo 'Running the Fourier transforms from' $(pwd)
	screen -dm bash birdies_script.sh
	echo 'Going back to main directory.'
	cd ..
	#Loop over the two halves of an observation.
	for half in $(seq 0 1); do
		echo ""
		echo ""
		echo "Working on the ${half}-th half of pointing ${pointing}"
		#Record the satring time, and sample size of every beam and write them in headers.txt
		IFS=' ' read -a beams <<< "000 476 460 026 025 475 461"
		echo ""
		echo ""
		echo "Reading the headers of beams ${beams[@]}"
		for beam in ${beams[@]}; do
			echo ""
			echo "Working on beam cfbf00${beam}"
			singularity exec -B /:/data:ro /beegfs/u/mcbernadich/simages/ProtoSearch_SIGPROC_v5.sif bash readHeader.sh /data${path}/${pointing}/cfbf00${beam} $half
		done
		#Read headers.txt to establish the first and last sample for each beam and write it into intervals.ascii.
		echo ""
		echo ""
		echo "Computing starting and ending samples for every file."
		echo "Beam, starting sample, ending sample:"
		python3 writeStart.py
		rm headers.txt
		#Chop the files according to the info in intervals.ascii.
		echo ""
		echo ""
		echo "Chopping the files from beams ${beams[@]}"
		IFS=' ' read -a index <<< "1 2 3 4 5 6 7"
		i=0
		while IFS= read -r line; do
			IFS=' ' read -a args <<< $line
			echo ""
			echo "Working on beam ${args[0]}"
			singularity exec -B /:/data:ro /beegfs/u/mcbernadich/simages/peasoup_cuda10.2.sigm bash chopCall.sh /data${path}/${pointing}/${args[0]} 32768 ${args[1]} ${args[2]} 7 ${index[${i}]} $half
			i=$[${i}+1]
		done < intervals.ascii
		rm intervals.ascii
	done
	#Create the combinated rfifind mask
	echo ""
	echo ""
	echo "Creating the multichannel mask for the observation. rfifind logs will be written at "${name}"_multibeam_rfifind_run.txt"
	singularity exec -B /:/data:ro /beegfs/u/ebarr/singularity_images/fold-tools-2020-11-18-4cca94447feb.simg rfifind -ncpus 8 -time 6 -freqsig 4 -intfrac 0.1 -o ${name}_multibeam -filterbank *.chop > ${name}_multibeam_rfifind_run.txt
	rm *.chop
	#Translate the masks into a frequency range.
	echo ""
	echo ""
	echo "Translating the mask into a format readable by peasoup."
	singularity exec -B /:/data:ro /beegfs/u/ebarr/singularity_images/fold-tools-2020-11-18-4cca94447feb.simg python rfifind_stats_noplot.py ${name}_multibeam_rfifind.stats
	singularity exec -B /:/data:ro /beegfs/u/ebarr/singularity_images/fold-tools-2020-11-18-4cca94447feb.simg weights_to_ignorechan.py ${name}_multibeam_rfifind.weights > ${name}_multibeam_rfifind_zap_channels.ascii
	frequencies=$(python3 translate.py ${name}_multibeam_rfifind_zap_channels.ascii)
	echo ${frequencies} > ${name}_multibeam_rfifind_zap_frequencies.ascii
	echo ""
	echo ""
	echo "Using parts of the srcipt rfifind_getout from V. Balakrishnan and M. Cruces, maintained by P. Padmanabh (Modified for docker), version 15.10.19"
	echo ""
	python getout_rfifind.py ${name}_multibeam_rfifind.mask ${name}_multibeam_rfifind
	echo ""
	echo "Reading birdies from the mask."
	sed -e '1,/Total number of intervals in the data: /d' ${name}_multibeam_rfifind_run.txt
	sed -e '1,/#  Sigma     Period(ms)      Freq(Hz)       Number /d' ${name}_multibeam_rfifind_run.txt > ${name}_multibeam_level1.txt
	sed -e '/Ten most numerous birdies:/,$d' ${name}_multibeam_level1.txt > ${name}_multibeam_level2.txt
	sed -i '1d' ${name}_multibeam_level2.txt
	sed 's/|/ /' ${name}_multibeam_level2.txt | awk '{print $4}' > ${name}_multibeam_level3.txt
	sed -e '1,/#  Number    Period(ms)      Freq(Hz)       Sigma /d' ${name}_multibeam_level1.txt > ${name}_multibeam_level4.txt
	sed -i '1d' ${name}_multibeam_level4.txt
	sed -i '$d' ${name}_multibeam_level4.txt
	sed -i '$d' ${name}_multibeam_level4.txt
	sed 's/|/ /' ${name}_multibeam_level4.txt | awk '{print $4}' >> ${name}_multibeam_level3.txt
	sed -i "s/([^)]*)//g" ${name}_multibeam_level3.txt
	sed -i '/^\s*$/d' ${name}_multibeam_level3.txt
	cat ${name}_multibeam_level3.txt | sort -u > ${name}_multibeam_rfifind.birdies
	rm -f ${name}_multibeam_level*.txt
	sed -i "s/$/\t0.15/" ${name}_multibeam_rfifind.birdies
	echo ""
	echo ""
	echo "Translating the frequencies and birdies into a format readable by peasoup."
	rfifind_birdies=$(python3 readBirdies.py ${name}_multibeam_rfifind.birdies)
	multibeam_birdies=$(python3 zapFourier.py ${name} "${name}_Fourier/*_0dm_time_series_red.fft" 0.00015312149)
	#Write it all into a sql script.
	echo 'INSERT INTO rfi_masks (utc, frequency_mask, birdie_list) VALUE ("'${utc_start}'", "'${frequencies}'", "1.65925:0.002,3.31785:0.002,6.6357:0.002,5.55556:0.002,11.1111:0.002,'${rfifind_birdies}','${multibeam_birdies}'");' >> zappingList.sql
	echo ""
	echo ""
	echo "Pointing ${pointing} completed!"
	echo "|--------------------------------------------------------------------------------------------------|"
done
python3 computeMasks.py "*zap_channels.ascii" > fractionList.ascii
echo ""
echo ""
echo ""
echo "Done! Have a nice day! Or a bad one, because there is nothing more frustrating than being told 'Have a nice day' when we are having a bad one."