#!/bin/bash
#		*****	High Order Priorities	*****
# Path of the main directory
#	!! Attention: / at the end
path='/home/siavash/Workplace/DATA/ADJOINT/gmt_402/'
#cname
cname=v402
# Higher and lower bound of the color pallate
lower_bound=-100
upper_bound=100
#Time Duration for the captions
time_beginning=16
time=16
#Total number of gmt outputs for the specific simulation
tot_t_num=5
# The time_step between every two outputs
time_step=$(echo "scale = 1; $time/($tot_t_num-1)" | bc)
# nth of the iteration
declare -a depth=(0000)
# iTH iteration to be plotted
declare -a iteration_all=(01)
#		***** 	Second Order	*****
# Setting the region on the map
lon1=-180
lon2=180
lat1=-89
lat2=+89
size=12
# Projection Style
JX=-JX$(python -c "print 2 *$size")d/$(expr 1 \* $size)d
MW=-JW0/$(python -c "print 2 *$size")
Projection=$MW

# Interpolation
x_grid_space=1.5
y_grid_space=1.5

# GMT color palette
cpt_mode=jet  
interval=$(echo ${upper_bound} - ${lower_bound} | bc)
interval=$(echo "scale = 1; $interval / 5" | bc)
#Creating GMT color Palette
#makecpt -C$cpt_mode -T$lower_bound/$upper_bound/$interval -Z > colors.cpt
makecpt -Cpolar2.cpt -T$lower_bound/$upper_bound/$interval -Z -D > colors.cpt
#	*****	For loop for plotting everything	*****
for ((k=0; k<=${#iteration_all[@]}-1; ++k )); do
iteration=${iteration_all[$k]}
for ((i=0; i<=${#depth[@]}-1; ++i )); do
echo ${depth[$i]}" km"
declare -a name=($(ls $(echo ${path}${cname}"."${depth[$i]}"*_"${iteration})))
for ((j=0; j<=${#name[@]}-1; ++j )); do
#for ((j=0; j<=3; ++j )); do
full=$(echo ${name[$j]})
full_len=${#full}
out_num=${full:$full_len-5:2}
echo ${out_num}" of "${#name[@]}
# Conversion of latitude and longitude to GMT grid NETCDF(Prob!) 
xyz2grd ${name[$j]} -G"grid"${i}"-"${j}".grd" -R$lon1/$lon2/$lat1/$lat2 -I$x_grid_space/$y_grid_space 
# Plot the gridded image
grdimage "grid"${i}"-"${j}".grd" -Ccolors.cpt -R$lon1/$lon2/$lat1/$lat2 $Projection \
 -E300 -K > $cname"-out"${i}"-iter"${j}".ps"
## Add the coastline information
pscoast -R $Projection -Dc -W0.1 -A10000 \
 -K -O >> $cname"-out"${i}"-iter"${j}".ps"
#pstext -R $Projection -G0 -O -K << EOF >> $cname"-out"${i}"-iter"${j}".ps"
pstext -R -F+f15 $Projection -O -K -N << EOF >> $cname"-out"${i}"-iter"${j}".ps"
0 -90 $(echo $time_beginning - ${time_step}*$j | bc)" Ma ago"
EOF
## Add a scale bar of the colors
psscale -D$(expr 1 \* $size)/$(python -c "print 1.2 *$size")/$(expr 2 \* $size)/.6h -O \
-Ccolors.cpt -B$interval >> $cname"-out"${i}"-iter"${j}".ps"
ps2pdf $cname"-out"${i}"-iter"${j}".ps" $cname"-depth"${depth[$i]}"-out"${out_num}".pdf" 
rm *grd *ps
done
mkdir -p Kino
pdfjam --landscape --suffix 'Kino' *pdf
mv *Kino.pdf ./Kino/$cname"-depth"${depth[$i]}"-Iter-"${iteration}"kino.pdf"
rm *pdf
done
done
## Remove the temporary files

