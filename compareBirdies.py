import sys
import numpy as np
#This code compares the 0dm birdies from each beam. If they are repeated in all beams, the bridie is added to the birdies list.
#sys.argv[1] is a list with the names of files we want to look for

def compareBirdies(beams_list):
	beams_list=beams_list.split(" ")
	#Put all of the birdies into a single, big, list.
	birdies=[]
	for beam in beams_list:
		read_file=open(beam+"_0dm_time_series.lis")
		for line in read_file:
			birdies.append(float(line.split(" ")[1]))
	#Compare all of the birdies and store those which are similar into another list
	#Turn the birdies into frequencies and order them by ascending order.
	birdies=np.sort(1/np.array(birdies))
	#This is the list of repeated birdies.
	store=[]
	while birdies.size<=1:
		#At a given birdie, loop over al birdies with frequencies larger than itself.
		i=1
		entry=str(birdies[0])
		for birdie in birdies[1:]:
			new_birdies=birdies
			#Copmpare the 0th one wth the others. See if any is found that has the same value or that of a higher harmonic.
			#If so, write them down.
			if ( np.isclose(birdie,birdies[0],atol=np.amax(birdie,birdies[0])/1000)[1] or
				np.isclose(birdie,2*birdies[0],atol=np.amax(birdie,2*birdies[0])/1000)[1] or
				np.isclose(birdie,3*birdies[0],atol=np.amax(birdie,3*birdies[0])/1000)[1] or
				np.isclose(birdie,4*birdies[0],atol=np.amax(birdie,4*birdies[0])/1000)[1] or
				np.isclose(birdie,5*birdies[0],atol=np.amax(birdie,5*birdies[0])/1000)[1] or
				np.isclose(birdie,6*birdies[0],atol=np.amax(birdie,6*birdies[0])/1000)[1] or
				np.isclose(birdie,7*birdies[0],atol=np.amax(birdie,7*birdies[0])/1000)[1] or
				np.isclose(birdie,8*birdies[0],atol=np.amax(birdie,8*birdies[0])/1000)[1] ):
				#Write it down.
				entry=entry+","+str(birdie)
				#Delete the matched birdie.
				new_birdies=np.delete(new_birdies,i)
			i=i+1
		#Store the entry
		store.append(entry)
		#Delete the first birde
		new_birdies=np.delete(new_birdies,0)
		#Restat the birdies list with the eleminated values.
		birdies=new_birdies
	return store
	#Print the output in a way that is understandable by an sql script, and in frequencies.
#	birdies=""
#	store=np.array("store")
#	frequencies=""
#	for entry in store:
#		entry=entry.split(",").astype("float")
#		harmonics=np.round(entry/entry[0])
#		entry=entry/harmonics
#		if np.size(entry)==7 
#		i=1
#		while i<=8:
#			birdie_start=str(i*np.amin(line[0])*(1-1/2000))
#			birdie_end=str(i*np.amax(line[0])*(1+1/2000))
#			birdies=birdies+birdie_start+":"+birdie_end+","
#			i=i+1
#	birdies=birdies.rsplit(",",1)[0]
#	return birdies

print(compareBirdies(sys.argv[1]))
