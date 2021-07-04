import sys
import numpy as np
import glob
import matplotlib.pyplot as plt
#Compare the fourier transforms of different beams and return a list of birdies to zap.
#As arguments, it takes the anme of the pointing,
# a list of de-reddened time fft of arbitray size
# and the time-step of the oroginal series.

#Useful for plotting. Not really used in the script.
def zap_birdies(frequency_series,birdies_file):
	birdies=open(birdies_file,"r")
	birdies_mask=True
	for line in birdies:
		line=line.split(" ")
		birdies_mask=birdies_mask*np.array( (frequency_series < float(line[0])) | (frequency_series > float(line[1])) ) 
	birdies.close()
	return birdies_mask

#Not used in the script either. rednoise already gives a good normalisation.
def normalise(series):
	mean=np.mean(series)
	dev=np.std(series)
	normalised_series=np.sqrt(4)*(series-mean)/dev+np.sqrt(4)*mean/dev
	return normalised_series

#Run several filtermach sizes across the Fourier series and pick the highest S/N for each bin. 
def blurSeries(fourierPower):
	#Convolve the fourier seires with a sinc function of several sizes. i=1 preserves the original fourier series.
	convolved_array=np.array([np.convolve(fourierPower,np.sinc(np.arange(-1,1+2/(2*i),2/(2*i))),"same")/np.sqrt(2*i-1) for i in range(1,7)])
	#Pick the highest S/N i for ach bin.
	scrunched_array=np.max(convolved_array,axis=0)
	return scrunched_array

#Write a 
def writeBirdies(name,fourier_list,time_step):
	#Open the files where the logs will be written.
	logs=open(name+"_multibeam_birdies_logs.txt","w")
	fourier_series_ar=[]
	size_check=False
	#Store the fourier powers in a numpy array.
	for beam in fourier_list:
		fourier_series_ar.append(np.square(np.absolute(np.fromfile(beam,dtype="float32"))))
		if size_check==False:
			#Record the size of the fft and make a frequency series.
			fourier_size=fourier_series_ar[0].size
			frequency_series=np.fft.fftfreq(fourier_size,time_step)
			size_check=True
	fourier_series_ar=np.array(fourier_series_ar)
	#Run the filtermach on each fourier power series.
	i=0
	for array in fourier_series_ar:
		fourier_series_ar[i]=blurSeries(array)
		i=i+1
	#Compute the number of beams in which a signals needs to overcome the threshold to be zapped (min:beams).
	nbeams=len(fourier_series_ar)
	min_beams=int(np.round(nbeams/2))+1
	#Compute the threshold in each beam.
	threshold=np.log(fourier_size/2)
	logs.write("There are {} beams.\n".format(nbeams))
	logs.write("Signals appearing in {} beams will be zapped.\n".format(min_beams))
	logs.write("The threshhold is P=-ln(1/2*{})={}\n".format(fourier_size,threshold))
	logs.write("The mean value and std of beams are {} and {}\n".format(np.mean(fourier_series_ar),np.std(fourier_series_ar)))
	#Create an array fo zeros of half the size as the array with the fourer series.
	#The fourier series is halved here to account for the simmetry in the fft.
	binary_array=np.zeros((nbeams,fourier_size//2),dtype='int')
	#Turn into 1's every bin where the corresponding filter-matched fourier power is above the threshold.
	binary_array[fourier_series_ar[:,:fourier_size//2] > threshold]=1
	#Sum the binary array across the beams. There where the sum is larger than min_beams, the bins will be zapped. 
	zapping_array=( np.sum(binary_array,axis=0) >= min_beams )
	#Compute the simple zapping fraction.
	zapping_fraction=zapping_array[zapping_array==True].size/zapping_array.size
	logs.write("{}% of Fourier bins have been zapped.\n".format(zapping_fraction*100))
	#Write the birdies in a file that can be read later on.
	i=0
	start=False
	#Create empty string where birdies will be written.
	birdies=""
	#This can be read by sigproc.
	write_file=open("multibeam_birdies","w")
	#Store the birdies by going 1 bin forward and 1 bing backward.
	for element in zapping_array:
		if element==True and start==False:
			birdie_start=frequency_series[i-1]
			start=True
		elif element==False and start==True:
			#Compute the central bin and width of each birdie.
			birdie_end=frequency_series[i]+frequency_series[1]/2
			birdie_width=str(float(birdie_end)-float(birdie_start))
			birdie_central=str((float(birdie_end)+float(birdie_start))/2)
			#Add them to the string. The final coma signals the division from the next birdie.
			birdies=birdies+birdie_central+":"+birdie_width+","
			#This is what can be read by sigproc. Comment it in if you want it.
			#write_file.write("{} {} 1\n".format(birdie_start,birdie_end))
			start=False
		i=i+1
	write_file.close()
	#Remove the final coma.
	birdies=birdies.rsplit(",",1)[0]
	logs.write("Resulting birdies:\n")
	logs.write(birdies)
	return birdies

print(writeBirdies(sys.argv[1],glob.glob(sys.argv[2]),float(sys.argv[3])))
