#! /bin/bash

# Path of the main directory of the xyz files
#     (!!) Remember to add '/' in the end
path='/import/borgcube03-data/sghelichkhani/gmt_410/'
# legacy terra case name
cname=t401

lower_bound=-20
upper_bound=20

#Time Duration for the captions
time=100
#Total number of gmt outputs for the specific simulation
tot_t_num=26

time_step=$(echo "scale = 2; $time/($tot_t_num-1)" | bc)

# nTH output file in each iteration to be plotted
declare -a suffix1=(00)

# iTH iteration to be plotted
iteration=06
# Km depth to be plotted
#declare -a depths=(0450 0720 1260 1630 2080)
#depths=$(ls ${cname}"."*"."${suffix1[0]})
#declare -a depths=(2170 2440 2620 2710 2800)

tot_size=20
x_size=20
y_size=15

font_size=15

y_dist=$(echo $(echo "scale = 2; $y_size/2" | bc) - 0.5 | bc)

## Number of the subplots in total
TotSub=$(echo ${#suffix1[@]}*${#suffix2[@]} | bc)

## Based on the number of the subplots determine the whole size of the plot
#Size=2.5

# Map Projection
# Projection Style
#JX=-JX$(python -c "print 2 *$size")d/$(expr 1 \* $size)d
#MW=-JW0/$(python -c "print 2 *$size")d

# Setting the region on the map
lon1=-180
lon2=180
lat1=-90
lat2=+90

# Interpolation
x_grid_space=2
y_grid_space=2

# GMT color palette
cpt_mode=jet
tick_note=$(echo $(echo $upper_bound - $lower_bound | bc) / 5 | bc)

interval=$(echo $(echo $upper_bound - $lower_bound | bc) / 5 | bc)

#Creating GMT color Palette
makecpt -C$cpt_mode -T$lower_bound/$upper_bound/$interval -Z > colors.cpt
# Loop creating the grid files
for ((i=0; i<=${#suffix1[@]}-1; ++i )); do
declare -a name=($(ls $(echo ${path}${cname}".*."${suffix1[$i]})"_"${iteration}))
for ((j=0; j<=3-1; ++j )); do
#for ((j=0; j<=${#name[@]}-1; ++j )); do

full=$(echo ${name[$j]})
#lenfull=$(#full)
xCoor=$(echo $(echo ${x_size}*${i} | bc) + 1 | bc)
yCoor=$(echo $(echo ${y_size}*${j} | bc) + 1 | bc)
#name=$(echo ${path}${cname}"."${depths[$j]}"."${iteration}"_"${suffix1[$i]});
# Conversion of latitude and longitude to GMT grid NETCDF(Prob!) 
xyz2grd ${name[$j]} -Ggrid${i}"-"${j}".grd" -R$lon1/$lon2/$lat1/$lat2 -I$x_grid_space/$y_grid_space -V
#grdimage -V grid${i}"-"${j}".grd" -Yf${yCoor}"c" -Xf${xCoor}"c" -Ccolors.cpt -Rd -JW0/${tot_size} -Ei -K > It${iteration}-d${j}-${suffix1[$i]}".ps"
grdimage -V grid${i}"-"${j}".grd" -Ccolors.cpt -Rd -JW0/${tot_size} -Ei -K > It${iteration}-d${depths[$j]}-${suffix1[$i]}".ps"
pscoast -JW${tot_size} -Rd -W0.9p -Dc -O -A0/0/1 >> It${iteration}-d${j}-${suffix1[$i]}".ps"
#pstext -Rd -JW${tot_size} -F+f$font_size"p" -O -N -Y-$y_dist"c" -X  >> It${iteration}-d${j}-${suffix1[$i]}".ps" << END
#0 0 km, $stage_time Ma ago
#END
#temp1=$(echo $(echo "scale = 2; ${#suffix1[@]}/2" | bc) - 1 | bc)
#x_center=$(echo $temp1*${x_size} | bc)
#colorbar=$(echo $x_size*${#suffix1[@]} | bc)
#psscale -D-$x_center"c"/$(echo $y_size + 2.5 | bc)"c"/$colorbar"c"/0.25ch  -Ccolors.cpt -O -S -B$tick_note:"temperature variations [%]":/:: -E >> It${iteration}-d${depths[$j]}-${suffix1[$i]}".ps"
done
done
#ps2pdf $output".ps" $output".pdf"
rm *.grd *.cpt 
#gv It${iteration}-d${j}-${suffix1[$i]}".ps"

