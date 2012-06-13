reset
set terminal wxt enhanced

source='ra226'
clover='clover1'
clover='clover1'
leaf='leaf0'

fileCommand(m,n,o,p) = sprintf('< paste %s.dat %s-%s-%s.dat',m,n,o,p)
graphTitle(n,m,o) = sprintf("Energy vs. Centroid\n%s %s - using %s",n,m,o)
psName(n,m,o) = sprintf("%s-%s-%s.ps",n,m,o)

a=1.
b=1.
c=1.

f(x)=a*x**2+b*x+c

fit f(x) fileCommand(source,clover,leaf,fileName) u 3:2 via a,b,c

set title graphTitle(clover,leaf,fileName)
set xlabel "Centroid (arb)"
set ylabel "Energy (keV)"
unset key

set label 1 sprintf("f(x) = %g (1/keV) x^2 + %g keV * x + %g keV",a,b,c) at 50, 2300

set yrange [-500:2500]
set y2range [-1:5]
set y2tics border

set x2zeroaxis lt -1

plot fileCommand(source,clover,leaf,fileName) u 3:2, f(x), \
     fileCommand(source,clover,leaf,fileName) u 3:($2-f($3)) axes x1y2

set terminal postscript enhanced color solid
set output pngName(clover,leaf,fileName)
replot