import sys
from sigpyproc import Readers, Filterbank, Header

#name: name of the filterbank.
#out_name: first name of the oytput file (necessary for ordering)
#sample_step: sample size of every chopped chunk of the observation
#first_sample: sample index of the first sample included in the chopping.
#last_sample: sample index of the last sample included in the chopping.
#n_section: how many beams are we iterating through
#section_index: which section of the beam loop are we in. If 1, it is the first chunch. If n_section, it is the last chunck.
def filterbank_chop(name,out_name,sample_step,first_sample,last_sample,n_sections,section_index):
	#Read the filterbank.
	data=Readers.FilReader(name)
	#Compute the step of the loop.
	total_sample_step=sample_step*n_sections
	#Compute how many loops are in there.
	sample_size=last_sample-first_sample+1
	total_complete_steps=int(sample_size/total_sample_step)
	#Decide if the last step for this file should be included or not.
	if total_complete_steps*total_sample_step+section_index*sample_step-1 < sample_size:
		total_steps=total_complete_steps+1
		complete="yes"
	else:
		total_steps=total_complete_steps
		complete="no"
	#Stablish the length of the initial sample name.
	sample_length=len(str(sample_size))
	#Start the loop.
	i=0
	while i<total_steps:
		sub_first_sample=total_sample_step*i+sample_step*(section_index-1)+first_sample
		print("Working from sample "+str(sub_first_sample))
		data.split(sub_first_sample,sample_step,filename="{}_{}_{}.chop".format(out_name,str(sub_first_sample).zfill(sample_length),name.split(".")[0]))
		i=i+1
	if complete=="no":
		if total_steps*total_sample_step+(section_index-1)*sample_step < sample_size:
			sub_first_sample=total_sample_step*i+sample_step*(section_index-1)+first_sample
			print("Working from sample "+str(sub_first_sample))
			data.split(sub_first_sample,sample_size-(total_sample_step*i+sample_step*(section_index-1)),filename="{}_{}_{}.chop".format(out_name,str(sub_first_sample).zfill(sample_length),name.split(".")[0]))
	return "Chopped file {}".format(name)

print(filterbank_chop(sys.argv[1],sys.argv[2],round(float(sys.argv[3])),round(float(sys.argv[4])),round(float(sys.argv[5])),int(sys.argv[6]),int(sys.argv[7])))