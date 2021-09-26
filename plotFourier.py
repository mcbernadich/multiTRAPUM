import numpy as np
import sys
import matplotlib.pyplot as plt
# Simply plot the fourier transform of a specific DM trial.
# The info is read from the {pulsar name}_{i}_fourier.ascii file,
# produced by findPeriod.py in findPulsar.sh.
# The second argument is the period, and the third one is the amount of harmonic summings.

def zap_birdies(frequency_series,birdies_file):
	file=open(birdies_file,"r")
	line=file.readline()
	line=file.readline()
	line=file.readline()
	line=file.readline()
	line=file.readline()
	line=file.readline()
	birdies_mask=True
	birdies=file.readline()
	birdies=birdies.split(",")
	for interval in birdies:
		interval=interval.split(":")
		birdies_mask=birdies_mask*np.array( ( frequency_series < float(interval[0])-float(interval[1])/2 ) | ( frequency_series > float(interval[0])+float(interval[1])/2 ) ) 
	file.close()
	return birdies_mask

fourier_series_dered=np.square(np.absolute(np.fromfile("SextansA_cfbf00005_0dm_time_series_red.fft",dtype="float32")))
fourier_size=fourier_series_dered.size
fourier_series_dered=fourier_series_dered[:fourier_size//2]
frequency_series=np.fft.fftfreq(fourier_size, 2 * 16 * 4096 / 856e6)[:fourier_size//2]
birdies_mask=zap_birdies(frequency_series,"SextansA_multibeam_birdies_logs.txt")
print(np.mean(fourier_series_dered))
print(np.std(fourier_series_dered))

plt.plot(frequency_series,fourier_series_dered,color="r",label="unzapped")
plt.plot(frequency_series[birdies_mask],fourier_series_dered[birdies_mask],color="k",label="zapped")
plt.plot()
plt.xlabel("Frequency (Hz)")
plt.xlim(0,1000)
#plt.ylim(0,1500)
plt.title("Fourier spectrum")
plt.ylabel("Power")
plt.legend()
plt.show()