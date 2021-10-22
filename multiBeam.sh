#!/bin/bash

#Set the singularty image paths:
sing_presto='singularity exec -B /:/data:ro /beegfs/u/ebarr/singularity_images/fold-tools-2020-11-18-4cca94447feb.simg'
sing_sigproc='singularity exec -B /:/data:ro /beegfs/u/mcbernadich/simages/ProtoSearch_SIGPROC_v5.sif'
sing_sigpyproc='singularity exec -B /:/data:ro /beegfs/u/mcbernadich/simages/peasoup_cuda10.2.sigm'
sing_filtool='singularity exec -B /:/data:ro /beegfs/u/ebarr/singularity_images/fbfhn01.mpifr-be.mkat.karoo.kat.ac.za_7000_trapum_search:cuda10.2-20211008-2021-10-08-0326eec5797c.simg'

echo ""
echo "|------------------------------------------------------------------------------------|"
echo "|-----Multi-beam channel mask producer using singularity, presto, sigproc and--------|"
echo "|-----sigpyproc.---------------------------------------------------------------------|"
echo "|-----Using getout_rfifind.py from P. Padmanabh and parts of rfifind_getout----------|"
echo "|-----from V. Balakrishnan and M. Cruces, version 15.10.19 .-------------------------|"
echo "|------------------------------------------------------------------------------------|"
echo ""

#Parse the arguments fromt the arguments.txt file.
# It may seem redundant, but it is better this way than to write all of the arguments on a command screen.
# General arguments (path, pointing_list, rfifind_beams, birdies_beams and chop_samples) need to be set. Otherwise the code won't run.
# rfifind arguments (ncpus, time, timesig, freqsig, chanfrac and intfrac) will be the default ones unless specified.
# specific data parameters (band_bottom, band_middle, nchan, tsample) will be read from the header of files.
while IFS= read -r line; do
	IFS=": " read -a args <<< $line
	if [[ ${args[0]} = "path" ]]; then
		path=${args[1]}
	elif [[ ${args[0]} = "pointing_list" ]]; then
		pointing_list=${args[1]}
	elif [[ ${args[0]} = "rfifind_beams" ]]; then
		rfifind_beams=${args[1]}
	elif [[ ${args[0]} = "birdies_beams" ]]; then
		birdies_beams=${args[1]}
	elif [[ ${args[0]} = "chop_samples" ]]; then
		samples=${args[1]}
	elif [[ ${args[0]} = "ncpus" ]]; then
		ncpus=${args[1]}
	elif [[ ${args[0]} = "time" ]]; then
		time=${args[1]}
	elif [[ ${args[0]} = "timesig" ]]; then
		timesig=${args[1]}
	elif [[ ${args[0]} = "freqsig" ]]; then
		freqsig=${args[1]}
	elif [[ ${args[0]} = "chanfrac" ]]; then
		chanfrac=${args[1]}
	elif [[ ${args[0]} = "intfrac" ]]; then
		intfrac=${args[1]}
	fi
done < arguments.txt

#Check which variables have been set
if test $path; then
	echo "Masking pointings in ${path}"
	echo " "
else
	echo "Please specify path in arguments.txt"
	exit 1
fi
if test $pointing_list && [[ $pointing_list == "all" ]]; then
	echo "All of the pointings in this path will be masked."
	echo " "
	pointing_list=$(ls ${path})
elif test $pointing_list; then
	IFS="," read -a pointing_list <<< ${pointing_list}
	echo "Pointings to be masked: ${pointing_list[@]}"
	echo " "
else 
	echo "Please specify pointing_list in arguments.txt"
	exit 1
fi
if test $rfifind_beams; then
	echo "Pointings to be chopped and sent to rfifind: ${rfifind_beams}"
	echo " "
else
	echo "Please specify the beams to be chopped and un through rfifind in arguments.txt"
	exit 1
fi
if test $birdies_beams; then
	echo "Beams for the multibeam birdies: ${birdies_beams}"
	echo " "
else
	echo "Please specify the multibeam birdies beams in arguments.txt"
	exit 1
fi
if test $samples; then
	echo "rfifind beams will be chopped every ${samples} samples."
	echo " "
else
	echo "Please specify the chopping_samples in arguments.txt"
	exit 1
fi
if ! test $ncpus; then
	ncpus=1
fi
if ! test $time; then
	time=30
fi
if ! test $timesig; then
	timesig=10
fi
if ! test $freqsig; then
	freqsig=4
fi
if ! test $chanfrac; then
	chanfrac=0.7
fi
if ! test $intfrac; then
	intfrac=0.3
fi
echo "rfifind parameters are:"
echo "ncpus= ${ncpus}"
echo "time= ${time}"
echo "timesig= ${timesig}"
echo "freqsig= ${freqsig}"
echo "chanfrac= ${chanfrac}"
echo "intfrac= ${intfrac}"

#Loop over the pointings.
for pointing in ${pointing_list[@]}; do
	name=$(python3 findUTC.py ${path}/${pointing}/apsuse.meta boresight)
	utc_start=$(python3 findUTC.py ${path}/${pointing}/apsuse.meta utc_start)
	centre_frequency=$(python3 findUTC.py ${path}/${pointing}/apsuse.meta centre_frequency)
	bandwidth=$(python3 findUTC.py ${path}/${pointing}/apsuse.meta bandwidth)
	nchan=$(python3 findUTC.py ${path}/${pointing}/apsuse.meta coherent_nchans)
	tsamp=$(python3 findUTC.py ${path}/${pointing}/apsuse.meta coherent_tsamp)
	echo ""
	echo ""
	echo ""
	echo "|--------------------------------------------------------------------------------------------------|"
	echo "Working on pointing ${path}/${pointing} (${name}), with starting time ${utc_start}, center frequency at ${centre_frequency} Hz, bandwidth of ${bandwidth} Hz, ${nchan} channels, and sampling time of ${tsamp} s."
	echo ""
	echo ""
	echo "Setting up script to run the fourier transforms in the bakground."
	mkdir ${name}_Fourier
	echo "#!/bin/bash" > ${name}_Fourier/birdies_script.sh
	echo "IFS=',' read -a beams <<< '${birdies_beams}'" >> ${name}_Fourier/birdies_script.sh
	echo 'for beam in ${beams[@]}; do' >> ${name}_Fourier/birdies_script.sh
	echo '	'${sing_presto}' bash ../fourier0dm.sh /data'${path}'/'${pointing}'/${beam} '${name}'_${beam} > '${name}'_${beam}_logs.txt' >> ${name}_Fourier/birdies_script.sh
	echo "done" >> ${name}_Fourier/birdies_script.sh
	echo 'Moving to '${name}'_Fourier .'
	cd ${name}_Fourier
	echo 'Running the Fourier transforms from' $(pwd)
	screen -dm bash birdies_script.sh
	echo 'Going back to main directory.'
	cd ..
	#Loop over the two halves of an observation.
	for half in $(seq -w 0 $[$( ls ${path}/${pointing}/cfbf00000 | wc -l )-1]); do
		echo ""
		echo ""
		echo "Working on the ${half}-th part of pointing ${pointing}"
		#Record the satring time, and sample size of every beam and write them in headers.txt
		IFS=',' read -a beams <<< "${rfifind_beams}"
		echo ""
		echo ""
		echo "Reading the headers of beams ${beams[@]}"
		for beam in ${beams[@]}; do
			echo ""
			echo "Working on beam ${beam}"
			${sing_sigproc} bash readHeader.sh /data${path}/${pointing}/${beam} $half
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
		i=1
		while IFS= read -r line; do
			IFS=' ' read -a args <<< $line
			echo ""
			echo "Working on beam ${args[0]}"
			${sing_filtool} bash deRed.sh /data${path}/${pointing}/${args[0]} $half
			${sing_sigpyproc} bash chopCall.sh /data${path}/${pointing}/${args[0]} ${samples} ${args[1]} ${args[2]} ${#beams[@]} ${i} $half
			i=$[${i}+1]
		done < intervals.ascii
		rm intervals.ascii
	done
	#Create the combinated rfifind mask
	echo ""
	echo ""
	echo "Creating the multichannel mask for the observation. rfifind logs will be written at "${name}"_multibeam_rfifind_run.txt"
	${sing_presto} rfifind -ncpus ${ncpus} -time ${time} -timesig ${timesig} -freqsig ${freqsig} -intfrac ${intfrac} -chanfrac {chanfrac} -o ${name}_multibeam -filterbank *.chop > ${name}_multibeam_rfifind_run.txt
	rm *.chop
	#Translate the masks into a frequency range.
	echo ""
	echo ""
	echo "Translating the mask into a format readable by peasoup."
	${sing_presto} python rfifind_stats_noplot.py ${name}_multibeam_rfifind.stats
	${sing_presto} weights_to_ignorechan.py ${name}_multibeam_rfifind.weights > ${name}_multibeam_rfifind_zap_channels.ascii
	frequencies=$(python3 translate.py ${name}_multibeam_rfifind_zap_channels.ascii ${centre_frequency} ${bandwidth} ${nchan}) #Add arguments here to modify the bandwith
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
	multibeam_birdies=$(python3 zapFourier.py ${name} "${name}_Fourier/*_0dm_time_series_red.fft" ${tsamp})
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
