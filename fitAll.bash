#!/bin/bash
source=$1
fileName=$2

rm fitResults-$fileName.dat

currentSource=$(echo "source='$source'")
sed '4c\'$currentSource plot.gp > plot.temp
mv plot.temp plot.gp

currentFile=$(echo "file='$fileName'")
sed '5c\'$currentfile plot.gp > plot.temp
mv plot.temp plot.gp

for file in clover*-$fileName.dat
do
    temp=`basename $file -$fileName.dat` 
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
	>> fitResults-$source.dat
    
    awk '{if($2=="=") print $0}' temp.log >> fitResults-$source.dat
    echo -e "\n" >> fitResults-$fileName.dat
done
