#!/bin/bas
IFS=' ' read -a beams <<< "000 476 460 026 025 475 461"
for beam in ${beams[@]}; do
	singularity exec -B /:/data:ro /beegfs/u/mcbernadich/simages/ProtoSearch_SIGPROC_v5.sif bash findRFI.sh /data/beegfs/DATA/TRAPUM/SCI-20200703-MK-01/20210204-0011/20210222_072410/cfbf00${beam} cfbf00${beam}_multibeam
done