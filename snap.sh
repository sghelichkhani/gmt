#!/bin/bash
#		*****	High Order Priorities	*****
# Path of the main directory
#	!! Attention: / at the end
path='/import/borgcube03-data/sghelichkhani/gmt_357/'
#cname
cname=t357
# Higher and lower bound of the color pallate
lower_bound=-20000
upper_bound=20000
#Time Duration for the captions
time=100
#Total number of gmt outputs for the specific simulation
tot_t_num=26
# The time_step between every two outputs
time_step=$(echo "scale = 1; $time/($tot_t_num-1)" | bc)
# nth of the iteration
declare -a outid=(02 03)
# iTH iteration to be plotted
declare -a iteration_all=(04)
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
x_grid_space=2
y_grid_space=2

# GMT color palette
cpt_mode=jet  
interval=$(echo ${upper_bound} - ${lower_bound} | bc)
interval=$(echo "scale = 1; $interval / 6" | bc)
#Creating GMT color Palette
#makecpt -C$cpt_mode -T$lower_bound/$upper_bound/$interval -Z > colors.cpt
makecpt -C$cpt_mode -T$lower_bound/$upper_bound/$interval -Z > colors.cpt
#	*****	For loop for plotting everything	*****
for ((k=0; k<=${#iteration_all[@]}-1; ++k )); do
iteration=${iteration_all[$k]}
echo $k"/"$(echo ${#iteration_all[@]} - 1 | bc)
for ((i=0; i<=${#outid[@]}-1; ++i )); do
echo ${outid[$i]}" th output"
declare -a name=($(ls $(echo ${path}${cname}".*."${outid[$i]}"_"${iteration})))
for ((j=0; j<=${#name[@]}-1; ++j )); do
full=$(echo ${name[$j]})
full_len=${#full}
out_depth=${full:$full_len-10:4}
echo ${j}" of "$(echo ${#name[@]} - 1 | bc)" layers"
# Conversion of latitude and longitude to GMT grid NETCDF(Prob!) 
xyz2grd ${name[$j]} -G"grid"${i}"-"${j}".grd" -R$lon1/$lon2/$lat1/$lat2 -I$x_grid_space/$y_grid_space 
# Plot the gridded image
grdimage "grid"${i}"-"${j}".grd" -Ccolors.cpt -R$lon1/$lon2/$lat1/$lat2 $Projection \
 -E300 -K > $cname"-out"${i}"-iter"${j}".ps"
## Add the coastline information
pscoast -R $Projection -Dc -W0.1 -A10000 \
 -K -O >> $cname"-out"${i}"-iter"${j}".ps"
#pstext -R $Projection -G0 -O -K << EOF >> $cname"-out"${i}"-iter"${j}".ps"
pstext -R -F+f12 $Projection -O -K -N << EOF >> $cname"-out"${i}"-iter"${j}".ps"
0 -90 "Depth "$out_depth" km"
EOF
#0 -90 12 0 14 BC "Depth "$out_depth" km"
## Add a scale bar of the colors
psscale -D$(expr 1 \* $size)/$(python -c "print 1.2 *$size")/$(expr 2 \* $size)/.6h -O \
-Ccolors.cpt -B$interval >> $cname"-out"${i}"-iter"${j}".ps"
ps2pdf $cname"-out"${i}"-iter"${j}".ps" $cname"-depth"${out_depth}"-out"${outid[$i]}".pdf"
rm *grd *ps
done
mkdir -p Snap
pdfjam --landscape --suffix 'Snap' *pdf
mv *Snap.pdf ./Snap/$cname"-out"${outid[$i]}"-iter"${iteration}".pdf"
rm *pdf
done
done
## Remove the temporary files
rm *cpt

