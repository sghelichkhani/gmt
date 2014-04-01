#!/bin/bash
#		*****	High Order Priorities	*****
# Path of the main directory
#	!! Attention: / at the end
path='/import/borgcube03-data/sghelichkhani/gmt_410/'
#cname
cname=t401
# Higher and lower bound of the color pallate
lower_bound=-50
upper_bound=+50
#Time Duration for the captions
time=100
#Total number of gmt outputs for the specific simulation
tot_t_num=26
# The time_step between every two outputs
time_step=$(echo "scale = 1; $time/($tot_t_num-1)" | bc)
# nth of the iteration
declare -a suffix1=(00)
# iTH iteration to be plotted
iteration=06

input1=t401.2800.00_00
#		***** 	Second Order	*****
# Setting the region on the map
lon1=-180
lon2=180
lat1=-90
lat2=+90
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
interval=$(expr $(expr $upper_bound - $lower_bound) / 10)
#Creating GMT color Palette
#makecpt -C$cpt_mode -T$lower_bound/$upper_bound/$interval -Z > colors.cpt
makecpt -C$cpt_mode -T$lower_bound/$upper_bound/$interval > colors.cpt
#	*****	For loop for plotting everything	*****
for ((i=0; i<=${#suffix1[@]}-1; ++i )); do
declare -a name=($(ls $(echo ${path}${cname}".*."${suffix1[$i]})"_"${iteration}))
for ((j=0; j<=${#name[@]}; ++j )); do
echo ${name[$j]}
full=$(echo ${name[$j]})
# Conversion of latitude and longitude to GMT grid NETCDF(Prob!) 
xyz2grd ${name[$j]} -G"grid"${i}"-"${j}".grd" -R$lon1/$lon2/$lat1/$lat2 -I$x_grid_space/$y_grid_space 
# Plot the gridded image
grdimage "grid"${i}"-"${j}".grd" -Ccolors.cpt -R$lon1/$lon2/$lat1/$lat2 $Projection \
 -E200 -K > $cname"-out"${i}"-iter"${j}".ps"
## Add the coastline information
pscoast -R$lon1/$lon2/$lat1/$lat2 $Projection -Dc -W1/2/3/3/3 -A10000 \
 -K -O >> $cname"-out"${i}"-iter"${j}".ps"
pstext -R $Projection -G1 -O -K << EOF >> $cname"-out"${i}"-iter"${j}".ps"
0 0 24 0 14 BL DEPTH
EOF
## Add a scale bar of the colors
psscale -D$(expr 1 \* $size)/$(python -c "print 1.2 *$size")/$(expr 2 \* $size)/.6h -O \
-Ccolors.cpt -B$interval -O >> $cname"-out"${i}"-iter"${j}".ps"
done
done
## Remove the temporary files
rm colors.cpt *.grd
#