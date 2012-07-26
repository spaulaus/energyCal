#Copyright S. V. Paulauskas 2012
#Distributed under GPL v.3.0
#This gnuplot script will execute with fitAll.bash to
#  perform fits on data taken from LeRIBSS
#Associated file: fitAll.bash
reset
set terminal wxt enhanced

source='sourceFiles/73cu.dat'
folderName='73cu'
clover='clover3'
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

set label 1 sprintf("f(x) = %g (1/keV) x^2 + %g keV x + %g keV",a,b,c) at 500, 4000
set title graphTitle(clover,leaf,source)
set ylabel offset 2,0 "Energy (keV)"
unset key

set terminal postscript enhanced color solid "Helvetica" 12
set output psName(clover,leaf,fitType)

set multiplot
set size 1,0.6
set origin 0,0.4
plot fileCommand(source,folderName,clover,leaf) u 3:2, f(x)

set xlabel "Centroid (arb)"
unset title
set yrange [-1.5:1.5]
set size 1,0.4
set origin 0,0.0
plot fileCommand(source,folderName,clover,leaf) u 3:($2-f($3)), 0 lc -1

unset multiplot

