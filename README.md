energyCal
=========

For doing energy calibrations and gain matching with clovers. This will perform 
a linear, quadratic, and cubic fit to the calibration data. Currently the only 
supported calibration sources are the Y-88 Mixed Source, and a Ra-226 source.

To use:
1. run "./fitAll.bash sourceFiles/<sourceName>.dat <newFolderName>"
   -Where folder name is the name of the folder your data files and 
    results will be stored
2. After the completion of the command you will now have a set of empty 
   datafiles in <newFolderName>/data labeled cloverX-leafY.dat
3. These files should then be formatted in the following way.

   #Clover 1 - Leaf 0 - 212	
   X	   AREA	    %ERR	FWHM	FitLow FitHigh
   36.6	   73134    11.6	1.42	32     39
   147.9   123737   1.7		1.55	140    150
   ...

   You should have the same number of fit peaks as you have lines in your
   source file. The fitted peaks should be organized in ascending order.

4. Once the data files are completely populated rerun the same command as 
   previously.  This will now perform the fits on the data and populate the 
   <newFolderName>/results directory with the results.

Any questions/comments? 
=======================
Contact: S. V. Paulauskas - stanpaulauskas@gmail.com