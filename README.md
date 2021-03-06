Energy Cal
=========

For doing energy calibrations and gain matching with clovers. This will perform 
a linear, quadratic, and cubic fit to the calibration data. It will then create 
pdfs of the graphs, calibration files to copy into a cal.txt, and plain text 
data files of the fitted parameters. 

Currently the only tracked calibration sources are the Y-88 Mixed Source, a Ra-226 
source, and the calibration used for the 73Cu LeRIBSS data. You are welcome to 
create more source files and send them to me to be added to the list. 

To use:

1. Run 
   
   $ ./fitAll.bash <Number of Clovers> <newFolderName>

   This will generate the folders, empty data files, and other things 
   necessary for the working of the script. 
   ****NOTE****
   This only needs to be done once, when you initialize a directory. Otherwise 
   it will produce errors.

2. After the completion of the command you will now have a set of empty 
   datafiles in <newFolderName>/data labeled cloverX-leafY.dat.

3. These files should then be formatted in the following way.
   
   #Clover 1 - Leaf 0
   #X	   AREA	    %ERR	FWHM	FitLow FitHigh
   
   36.6   73134    11.6	1.42	32     39
   47.9  123737   1.7		1.55	140    150
   ...
   
   Every column after the first is completely optional, and just things I like
   to keep track of.   
      
   You should have the same number of fit peaks as you have lines in your
   source file, and the peak order *must* match with the order given in the 
   source file. 

4. Once the data files are completely populated run the following command:

   $ ./energyCal.bash sourceFiles/<sourceName> <newFolderName>

   This will now perform the fits on the data and populate the 
   <newFolderName>/results directory with the results. 


Any questions/comments?
======
Contact: S. V. Paulauskas - stanpaulauskas@gmail.com
