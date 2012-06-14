#Copyright S. V. Paulauskas 2012
#Distributed under GPL v.3.0
#This gnuplot script will execute with fitAll.bash to
#  perform fits on data taken from LeRIBSS
#Associated file: fitAll.bash
reset
set terminal wxt enhanced

source='sourceFiles/ra226.dat'
folderName='energyCal02'
clover='clover2'
leaf='leaf3'
fitType='quad'

fileCommand(m,n,o,p) = sprintf('< paste %s %s/data/%s-%s.dat',m,n,o,p)
graphTitle(n,m,o) = sprintf("Energy vs. Centroid\n%s %s - using %s",n,m,o)
psName(n,m,o) = sprintf("%s-%s-%s.ps",n,m,o)

a=1.
b=1.
c=1.
d=1.

f(x)=a*x**2+b*x+c

fit f(x) fileCommand(source,folderName, clover,leaf) u 3:2 via a,b,c

set title graphTitle(clover,leaf,source)
set xlabel "Centroid (arb)"
set ylabel offset 2,0 "Energy (keV)"
unset key

set label 1 sprintf("f(x) = %g (1/keV) x^2 + %g keV x + %g keV",a,b,c) at 50, 2300

set yrange [-500:2500]
set y2range [-1:5]
set y2tics border

set x2zeroaxis lt -1

plot fileCommand(source,folderName,clover,leaf) u 3:2, f(x), \
     fileCommand(source,folderName,clover,leaf) u 3:($2-f($3)) axes x1y2

set terminal postscript enhanced color solid
set output psName(clover,leaf,fitType)
replot