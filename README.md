# TRAPUM_multibeam_rfi

This is the current working version that I'm using to create masks for the MLGPS survey. As such some things are hard-codded and some others are accomodated to work in the environtment where I run it. Eventually, a more general version of the code will go to the ```main``` branch.
UPDATE: the ```main``` branch is now out. Use that one if your surey is any other than MLGPS!

## Usage

The best way to use it in its current state is to clone this in your prefered directory, and run:
```
bash initialize.sh ${directory}
```
Where ```${directory}``` simply stands for the directory where the data of the most recent pointings are stored. For instance, for the Jul 3 2021 data, ```${directory}="/beegfs/DATA/TRAPUM/SCI-20200703-MK-01/20210701-0007"```. This will create a folder with the name of last sub-folder in ```${directory}```, in the example ```20210701-0007```. Inside of this folder, there will be four more sub-folders, called ```1```, ```2```, ```3``` and ```4```, and a script named ```join.sh```. Which can be ignored until later.

Inside of ```1```, for instance, all the rellevant scripts will have been copied over, along with a newly created script called ```execute.sh```. The script just says:
```
#!/bin/bash
bash multiBeam.sh /beegfs/DATA/TRAPUM/SCI-20200703-MK-01/20210701-0007 0,9 > logs.txt
```
Which calls the main script for you. Similar scripts will be found in ```2```, ```3``` and ```4```, but instead of ```0,9```, they have other ranges. These ranges are important: they are the pointings that will be masked. If you write ```ls ${directory}```, you will see the pointigns appearing in order. The same order is taken by the ```multiBeam.sh``` call inside of each ``execute.sh``, and ```0,9``` indicates that pointings from 0 to 9 in the order in which they appear in ```ls ${directory}``` will be masked. Other ranges indicate other pointings in the same order.

Originally, that was it. Running ```bash execute.sh``` would do the rest of the job for you for the specified range. The masks are created cronologically, but by running the four scripts in the four folders in different screens, you can have fours masks being created at the same time. But since the introduction of follow-up observations, pointings with a number of beams other than 481 have been introduced. If the code stumbles upon them, it will get stuck. This is where the script ```count_pointings.sh``` will help you. Running
```
bash count_pointings.sh ${directory}
```
will print to you the number of beams in each pointings, and the number of fiilterbank files in cfbf0000. For instance:
```
bash count_pointings.sh	/beegfs/DATA/TRAPUM/SCI-20200703-MK-01/20210701-0007
```
reveals that the pointings 1 and 25:
```
...
1
/beegfs/DATA/TRAPUM/SCI-20200703-MK-01/20210701-0007/20210703_180927: 15
2021-07-03-18:09:32_cfbf00000_0000000000000000.fil 2021-07-03-18:09:32_cfbf00000_0000004012498944.fil 2021-07-03-18:09:32_cfbf00000_0000008024997888.fil 2021-07-03-18:09:32_cfbf00000_0000012037496832.fil
...
25
/beegfs/DATA/TRAPUM/SCI-20200703-MK-01/20210701-0007/20210703_224756: 15
2021-07-03-22:48:02_cfbf00000_0000000000000000.fil 2021-07-03-22:48:02_cfbf00000_0000004012498944.fil
...
```
have 15 beams each. Even more, ```/beegfs/DATA/TRAPUM/SCI-20200703-MK-01/20210701-0007/20210703_180927``` contains 4 filterbanks instead of 2. These correspond to the follow-up observations of ```J1806-2124``` and ```J1449-6339```. You want to avoid these pointings in the masking but just changing the ranges inside of the ```execute.sh``` scripts. Once this is done, you can safelly run the scripts in their own screens.

After all the masks have been created, just run the forementioned ```join.sh``` script with ```bash join.sh```, and all the enatires for the files ```zappingList.sql``` and ```fractionList.ascii``` will be collected.

## Questions and inquiries

Just write to mcbernadich#mpifr-bonn.mpg.de if you have any. Remember, this is a working version, and it is not intended to be the final version. A proper documentation will eventually be built too.