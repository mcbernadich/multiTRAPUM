import sys
# This code writes the birdies in a format readable by peasoup.
# sys.argv[1] should be the files you are looking for.

def readBirdies(birdies_file):
	read_file=open(birdies_file,"r")
	#Birdies file readable by sigproc
	write_file=open("rfifind_birdies","w")
	#Create empty string where birdies will be written.
	birdies=""
	for line in read_file:
		line=line.split(" ")
		line=line[0].split("	")
		i=1
		while i<=8:
			#Compute the central bin and widht of each birdie.
			birdie_start=str(i*float(line[0])*(1-1/1000))
			birdie_end=str(i*float(line[0])*(1+1/1000))
			birdie_width=str(float(birdie_end)-float(birdie_start))
			birdie_central=str((float(birdie_end)+float(birdie_start))/2)
			#Add them to the string. The final coma signals the division from the next birdie.
			birdies=birdies+birdie_central+":"+birdie_width+","
			#if i==1:
			#	#This is what can be read by sigproc. Comment it in if you want it.
			#	write_file.write("{} {} 8\n".format(birdie_start,birdie_end))
			i=i+1
	#Remove the final coma.
	birdies=birdies.rsplit(",",1)[0]
	return birdies

print(readBirdies(sys.argv[1]))
