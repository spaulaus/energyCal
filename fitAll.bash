#!/bin/bash
source=$1
folderName=$2
dataDir="$2/data"

if [ ! -d $folderName ]
then
    mkdir -p $dataDir
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

    gnuplot plot.gp

    tail -15 fit.log > temp.log

    echo -e ""$clover" - "$leaf"\n ----------" \
	>> fitResults.dat
    
    cat temp.log >> fitResults.dat
    #awk '{if($2=="=") print $0}' temp.log >> fitResults.dat
    echo -e "\n\n" >> fitResults.dat
done
rm temp.log
,makePdf *.ps fitResults.pdf
mv fitResults.* $folderName
rm *.ps
