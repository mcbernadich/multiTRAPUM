# multiTRAPUM

This is an RFI masking pipelined based on the multibeam nature of the TRAPUM pulsar surveys. The outputs are a channels mask based on rfifind and a birdies mask based on a multibeam comparisson ready to be given to PEASOUP as it is implemented on APSUSE. The user can choose which pointings to run it on, which beams to use, and their preferred settings specifications. And all it takes is a single bash command!

Used softwares: singularity, presto, sigproc, sigpyproc and filtools. getout_rfifind.py from P. Padmanabh and parts of rfifind_getout from V. Balakrishnan and M. Cruces, version 15.10.19.

## How does it work? Easy peasy explanation

### Frequency-domain channel masks: 

From a pointing, the user chooses a set of beams they want to get the channel mask out of. Say that your pointing has 480 beams. Then, perhaps you want to take the central beam and a ring of 6 beams far out in the edges. When running, the pipeline first de-reddens the beams with filtool and then it takes the 1st N time samples of beam 1 and stores them in a .chop file. Then, it takes the 2nd N samples of beam 2 and stores it in another .chop file... until it reaches the 7th N samples of beam 7. At this point, the loop starts again, taking the 8th N samples from beam 1. Rinse and repeat until the end of the observation is reached. Finally, rfifind is run on all of the concatendated .chop files or, as we call it behind the scenes, a "Frankeinbeam". Of course, the scrip makes sure that all of the .chop files are contiguous!

This code is very flexible. You can specify the order in which beams are run through, the samples that each slicing operation takes and the parameters used by rfifind. Technically, you can choose ALL of the beams if so you wish, or even just one beam and specify a slicing sample size larger than the total samples to ensure a standard rfifind run on a single beam. Choose at your convenience!

### Fourier-domain birdies mask:

From a pointing, the user chooses once again a set of beams to run the mutibeam Fourier domain matching filter. In this case, the chosen beams are taken in their entirety and a time series is take on of them with prepdata, which is then fourier transformed and de-reddened. Then, the de-reddened powers of beams are matched with each other. If a signal goes above power ```P=ln(2*size_fourier_transform)``` in ```int(np.round(Nbeams/2))+1``` or more beams, then the Foruier bins involved are masked and the frequency ranges are written as an iutpuy. These limits are based on 1.-) the false alarm probabilty and 2.-) the multibeam nature of the filter. For instance, if the user has take 4 beam, a signal will need to repeat in at lest 3 beams to be zapped. The more beams are taken, the closer to just half of the beams this limit goes.

Additionally, birdies outputed by rfifind are also included.

## Usage

### Setup:

Just clone this repository to your prefered place in APSUSE with ```git clone https://github.com/mcbernadich/multiTRAPUM```
The code assumes that you have python, python3, numpy and singularity. If this is the case, you are good to go.

### Initialization:

Inside of the repository folder you will see a large bunch of scripts. You only need to worry about ```initialize.sh```, ```arguments.txt``` and ```multiBeam.sh```. To intialize, check where the main directory where your pointing data lies at and decide a name for the folder where you want to run the pipeline. For instance, the command

```bash intialize.sh /beegfs/DATA/TRAPUM/SCI-20200703-MK-01/20210707-0029 20211015```

will create a directory called ${your_dir}/multiTRAPUM/20211015 and copy all of the scripts inside of it anew. You can also give it an already existing directory.

### Giving arguments:

Inside of the working directory created by intialize.sh, you will find a file called ```arguments.txt```. Make sure that you fill each entry accordingly. An example of how should the file look like is the following:

```
# general parameters
path: /beegfs/DATA/TRAPUM/SCI-20200703-MK-01/20210707-0029
pointing_list: 20211015_175510,20211015_174500,20211015_173450
rfifind_beams: cfbf00000,cfbf00476,cfbf00460,cfbf00026,cfbf00025,cfbf00475,cfbf00461
birdies_beams: cfbf00000,cfbf00476,cfbf00025,cfbf00461
chop_samples: 32768
# rfifind parameters
ncpus: 8
time: 6
timesig:
freqsig: 4
chanfrac:
intfrac: 0.1
# miscellaneous parameters
cleanup: yes
filtool: yes
```

The general parameters are absolutely needed for the pipeline, otherwise the code will just not run:

```path``` is the main direcotry where your pointings lie at. 

```pointing_list``` is a listing of the directories inside of ```path``` (pointings!) that you want to run the pipeline on, and they must be separated by comas. Since listing all of the pointings can be quite the hassle, the keyword ```pointing_list: all``` can be given instead to run all of the pointins inside of ```path```.

```rfifind_beams``` and ```birdies_beams``` are the listing of beams that you want to take for the frequency-domain masking and the Fourier-domain masking, and they must also be separated by comas. Mind that the order of the elents in the list actually affects the order in which they are run! It is also very recommended that ```rfifind_beams``` contins more beams than ```birdies_beams```, as the rfifind pipeline and the Fourier pipeline run in parallel, but you don't want the rfifind run finishing before the Fourier run!

```chop_samples``` is the amount of samples that each beam slice (.chop files) contains, and it is recommended to select a power of 2. The correct size of ```chop_samples``` should be decided upon the sampling time of your data.

rfifind parameters are, quite literally, the parameters taken by rfifind. If left blank, they will be the rfifind default values.

Miscellaneous parameters are those that specify certain running perks. Unless specified otherwise, they go to default.

```cleanup``` can be used to tell ```multiBeam.sh``` to not cleanup the .chop files and the time series and their fourier transforms with ```cleanup: no```. Otherwise, they are just deleted as a standard to not clutter memory usage.

```filtool``` allows you to disble running filtool on the beams before chopping by writing ```cleanup: no```. In general, using filtool is recommended as it removes rednoise from beams and eliminates sharp discontinuities in between beams that result in spurious artifacts deceted by rfifind. However, if your pipeline doesn't use filtool, then perhaps it is better to disable it in ```multiBeam.sh``` too, as these artifact only appear in 1/40 pointings. 

### Running the code:

Once the working directory has been initalized and ```arguments.txt``` has been filled by the user, just run the pipeline with ```bash multiBeam.sh``` inside of the working directory. Then wait for the results. Relax, go get lunch, and take a nap (or do some other work if you want!). 

### Collecting the output:

Once the pipeline has finished running, you can collect the masks in the created file ```zappingList.sql```. This file is a sql script containing ```INSERT INTO rfi_masks (utc, frequency_mask, birdie_list) VALUE ("*","*","*")``` entries to be fed to PEASOUP.

Additionally, there is the ```fractionList.ascii```, which lists the fraction of masked frequency channels and masked Fourier bins in %. This file is just an human-readable for of the output summary, but it useful to know, for example, whether one of your pointings has very bad RFI.

## Questions and inquiries

Just write to mcbernadich@mpifr-bonn.mpg.de if you have any.