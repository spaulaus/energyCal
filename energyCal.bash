#!/bin/bash
# Copyright S. V. Paulauskas 2012
# This script is published under GPL v.3.0
# A script to do energy calibrations and gain matching
#  for clover data taken at LeRIBSS
# Associated File: plot.gp

#Define some of the directories
source=$1
folderName=$2
dataDir="$2/data"
resDir="$2/results"
calDir="$2/cals"

function makePdf {
    gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=${psFiles[0]} -dBATCH \
	-dPDFFitPage $(
	for i in $(seq 1 $(expr ${#psFiles[@]} - 1)) 
	do  
	    echo -n "${psFiles[$i]} " 
	    done)
}

#The loop for the first run for a calibration
if [ ! -d $folderName ]
then
    mkdir -p $dataDir
    mkdir -p $resDir
    mkdir -p $calDir
    for i in `seq 1 $1`
    do
	for j in 0 1 2 3
	do
	echo -e "#Clover $i - Leaf $j \n" > \
	    $dataDir/clover"$i"-leaf"$j".dat
	done
    done
    exit
fi

#Do some preliminary cleanup and run the main body.
rm -f temp.log folderName/fitResults.* fit.log 

#find the maximum source energy
currentSource=$(echo "source='$source'")
sed '9c\'$currentSource plot.gp > plot.temp
mv plot.temp plot.gp

currentFolder=$(echo "folderName='$folderName'")
sed '10c\'$currentFolder plot.gp > plot.temp
mv plot.temp plot.gp

maxEnergy=`sort -k2 -n $source | tail -1 | awk '{print $2}'`
labelYPos=$(echo "labelYPos='$maxEnergy'")
sed '11c\'$labelYPos plot.gp > plot.temp
mv plot.temp plot.gp

for file in $folderName/data/*.dat
do
    temp=`basename $file .dat`
    clover=`echo $temp | awk -F\- '{print $1}'`
    leaf=`echo $temp | awk -F\- '{print $2}'`
    
    currentClover=$(echo "clover='$clover'")
    currentLeaf=$(echo "leaf='$leaf'")
    
    sed '12c\'$currentClover plot.gp > plot.temp
    mv plot.temp plot.gp
    sed '13c\'$currentLeaf plot.gp > plot.temp
    mv plot.temp plot.gp

    for fit in cube lin quad
    do
	fitType=$(echo "fitType='$fit'")

	if [[ $fit == cube ]]
	then
	    fitFunc='f(x)=a*x**3+b*x**2+c*x+d'
	    fitCommand="fit f(x) fileCommand(source,folderName, clover,leaf) u 3:2 via a,b,c,d"
	    label='set label 1 sprintf("f(x) = %g (1/keV^2) x^3 + %g (1/keV) x^2 + %g keV x + %g keV",a,b,c,d) at 250, labelYPos'
	elif [[ $fit == lin ]]
	then
	    fitFunc='f(x)=a*x+b'
	    fitCommand="fit f(x) fileCommand(source,folderName, clover,leaf) u 3:2 via a,b"
	    label='set label 1 sprintf("f(x) = %g keV x + %g keV",a,b) at 250, labelYPos'
	else
	    fitFunc='f(x)=a*x**2+b*x+c'
	    fitCommand="fit f(x) fileCommand(source,folderName, clover,leaf) u 3:2 via a,b,c"
	    label='set label 1 sprintf("f(x) = %g (1/keV) x^2 + %g keV x + %g keV",a,b,c) at 250, labelYPos'
	fi

	sed '14c\'$fitType plot.gp > plot.temp
	mv plot.temp plot.gp

	sed '25c\'$fitFunc plot.gp > plot.temp
	mv plot.temp plot.gp

	sed '27c\'"$fitCommand" plot.gp > plot.temp
	mv plot.temp plot.gp
	
	sed '29c\'"$label" plot.gp > plot.temp
	mv plot.temp plot.gp
	
	gnuplot plot.gp
	
	tail -15 fit.log > temp.log
	
	echo -e ""$clover" - "$leaf"\n ----------" \
	    >> fitResults-"$fit".dat
    
	cat temp.log >> fitResults-"$fit".dat
	echo -e "\n" >> fitResults-"$fit".dat
    done
done

for fit in quad lin cube
do
    declare -a psFiles=(fitResults-"$fit".pdf *-"$fit".ps)
    makePdf psFiles
        
    file=fitResults-$fit.dat
    temp=`awk '{if($2=="=") print $1,$3}' $file`

    echo $temp | tr 'a' '\n'> temp.out
    while read line 
    do 
	set -- $line
	
	if [[ $fit == "lin" ]]
	then
	    echo $3 $1 >> cals-lin.dat
	elif [[ $fit == "quad" ]]
	then
	    echo $5 $3 $1 >> cals-quad.dat
	elif [[ $fit == "cube" ]]
	then
	    echo $7 $5 $3 $1 >> cals-cube.dat
	fi
    done < temp.out
done
mv fitResults-*.* $resDir
mv cals-*.dat $calDir
rm *.ps temp.out temp.log


