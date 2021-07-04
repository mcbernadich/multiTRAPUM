import numpy as np
#Read the feaders file and write the sarting and ending sample for each file.
header=open("headers.txt","r")
write=open("intervals.ascii","w")
beam=[]
time_first=[]
samples=[]
sample_index="unset"
for line in header:
	line=line.split("\n")[0]
	line=line.split(":")
	if line[0]=="Data file                        ":
		beam.append(line[3].split("_")[1])
	if line[0]=="Time stamp of first sample (MJD) ":
		time_first.append(float(line[1]))
	if line[0]=="Number of samples                ":
		samples.append(int(line[1]))
	if line[0]=="Sample time (us)                 " and sample_index=="unset":
		sample_time=float(line[1])
		sample_index="set"
time_first=np.array(time_first)
length=np.array(samples)*sample_time/(1e6*3600*24)
end_time=time_first+length
latest_starting_time=np.amax(time_first)
delay=(latest_starting_time-time_first)*(1e6*3600*24)/sample_time
first_last_sample=(np.amin(end_time)-time_first)*(1e6*3600*24)/sample_time
i=0
for element in beam:
	print(element,delay[i],first_last_sample[i])
	write.write("{} {} {}\n".format(element,delay[i],first_last_sample[i]))
	i=i+1
header.close()
write.close()