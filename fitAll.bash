#!/bin/bash
# Copyright S. V. Paulauskas 2012
# This script is published under GPL v.3.0
# A script to do energy calibrations and gain matching
#  for clover data taken at LeRIBSS
# Associated File: plot.gp
source=$1
folderName=$2
dataDir="$2/data"
resDir="$2/results"

if [ ! -d $folderName ]
then
    mkdir -p $dataDir
    mkdir -p $resDir
    for i in 1 2
    do
	for j in 0 1 2 3
	do
	echo -e "#Clover $i - Leaf $j \n" > \
	    $dataDir/clover"$i"-leaf"$j".dat
	done
    done
    exit
fi

rm -f temp.log folderName/fitResults.* fit.log 

currentSource=$(echo "source='$source'")
sed '4c\'$currentSource plot.gp > plot.temp
mv plot.temp plot.gp

currentFolder=$(echo "folderName='$folderName'")
sed '5c\'$currentFolder plot.gp > plot.temp
mv plot.temp plot.gp

for file in $folderName/data/*.dat
do
    temp=`basename $file .dat`
    clover=`echo $temp | awk -F\- '{print $1}'`
    leaf=`echo $temp | awk -F\- '{print $2}'`
    
    currentClover=$(echo "clover='$clover'")
    currentLeaf=$(echo "leaf='$leaf'")
    
    sed '6c\'$currentClover plot.gp > plot.temp
    mv plot.temp plot.gp
    sed '7c\'$currentLeaf plot.gp > plot.temp
    mv plot.temp plot.gp

    for fit in cube lin quad
    do
	fitType=$(echo "fitType='$fit'")

	if [[ $fit == cube ]]
	then
	    fitFunc='f(x)=a*x**3+b*x**2+c*x+d'
	    fitCommand="fit f(x) fileCommand(source,folderName, clover,leaf) u 3:2 via a,b,c,d"
	    label='set label 1 sprintf("f(x) = %g (1/keV^2) x^3 + %g (1/keV) x^2 + %g keV x + %g keV",a,b,c,d) at 50, 2300'
	elif [[ $fit == lin ]]
	then
	    fitFunc='f(x)=a*x+b'
	    fitCommand="fit f(x) fileCommand(source,folderName, clover,leaf) u 3:2 via a,b"
	    label='set label 1 sprintf("f(x) = %g keV x + %g keV",a,b) at 50, 2300'
	else
	    fitFunc='f(x)=a*x**2+b*x+c'
	    fitCommand="fit f(x) fileCommand(source,folderName, clover,leaf) u 3:2 via a,b,c"
	    label='set label 1 sprintf("f(x) = %g (1/keV) x^2 + %g keV x + %g keV",a,b,c) at 50, 2300'
	fi

	sed '8c\'$fitType plot.gp > plot.temp
	mv plot.temp plot.gp

	sed '19c\'$fitFunc plot.gp > plot.temp
	mv plot.temp plot.gp

	sed '21c\'"$fitCommand" plot.gp > plot.temp
	mv plot.temp plot.gp
	
	sed '28c\'"$label" plot.gp > plot.temp
	mv plot.temp plot.gp
	
	gnuplot plot.gp
	
	tail -15 fit.log > temp.log
	
	echo -e ""$clover" - "$leaf"\n ----------" \
	    >> fitResults-"$fit".dat
    
	cat temp.log >> fitResults-"$fit".dat
    #awk '{if($2=="=") print $0}' temp.log >> fitResults.dat
	echo -e "\n" >> fitResults-"$fit".dat
    done
done
rm temp.log
for fit in quad lin cube
do
    ,makePdf *-"$fit".ps fitResults-"$fit".pdf
done
mv fitResults-*.* $resDir
rm *.ps
