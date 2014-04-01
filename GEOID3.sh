#! /bin/bash

# Path of the main directory of the xyz files
#     (!!) Remember to add '/' in the end
path='/import/borgcube03-data/sghelichkhani/gmt_410/'
# legacy terra case name
cname=t401
lower_bound=-50
upper_bound=+50

#Time Duration for the captions
time=100
#Total number of gmt outputs for the specific simulation
tot_t_num=26
time_step=$(echo "scale = 1; $time/($tot_t_num-1)" | bc)


# Name of the output file
output=t401_1

# nTH output file in each iteration to be plotted
declare -a suffix1=(00 05 10)

# iTH iteration to be plotted
iteration=05
# Km depth to be plotted
declare -a depths=(2440 2620 2800)

tot_size=8
x_size=8.5
y_size=6

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
Projection=JX15



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
tick_note=$(echo ($upper_bound - $lower_bound) / 5 | bc)

interval=$(expr $(expr $upper_bound - $lower_bound) / 6)

#Creating GMT color Palette
makecpt -C$cpt_mode -T$lower_bound/$upper_bound/$interval -Z > colors.cpt

# Loop creating the grid files
for ((i=0; i<=${#suffix1[@]}-1; ++i )); do
for ((j=0; j<=${#depths[@]}-1; ++j )); do 
#name=$(echo ${path}${cname}"."${depths[$j]}"."${iteration}"_"${suffix1[$i]});
name=$(echo ${path}${cname}"."${depths[$j]}"."${suffix1[$i]}"_"${iteration});
# Conversion of latitude and longitude to GMT grid NETCDF(Prob!) 
xyz2grd $name -Ggrid${i}"-"${j}".grd" -R$lon1/$lon2/$lat1/$lat2 -I$x_grid_space/$y_grid_space -V
done
done


# Loop creating the grid files
for ((i=0; i<=${#suffix1[@]}-1; ++i )); do
for ((j=0; j<=${#depths[@]}-1; ++j )); do 
# Plotting the gridded data
xCoor=$(echo $(echo ${x_size}*${i} | bc) + 1 | bc)
yCoor=$(echo $(echo ${y_size}*${j} | bc) + 1 | bc)
if [[ ${i} -eq 0 && ${j} -eq 0 ]]; then
grdimage -V grid${i}"-"${j}".grd" -Yf${yCoor}"c" -Xf${xCoor}"c" -Ccolors.cpt -Rd -JW0/${tot_size} -Ei -K > $output".ps"
pscoast -JW${tot_size} -Rd -W0.9p -Dc -K -O -A0/0/1 >> $output".ps"
stage_time=$(echo -${suffix1[$i]}*$time_step + $time | bc)
pstext -Rd -JW${tot_size} -F+f$font_size"p" -O -K -N -Y-$y_dist"c" -X  >> $output".ps" << END
0 0 ${depths[$j]} km, $stage_time Ma ago
END
elif [[ ${i} -eq ${#suffix1[@]}-1 && ${j} -eq ${#suffix2[@]} ]]; then
grdimage -V grid${i}"-"${j}".grd" -Yf${yCoor}"c" -Xf${xCoor}"c" -Ccolors.cpt -Rd -JW0/${tot_size} -Ei -O -K >> $output".ps"
pscoast -JW${tot_size} -Rd -W0.9p -Dc -K -O -A0/0/1 >> $output".ps"
stage_time=$(echo -${suffix1[$i]}*$time_step + $time | bc)
pstext -Rd -JW${tot_size} -F+f$font_size"p" -O -K -N -Y-$y_dist"c" -X >> $output".ps" << END
0 0 ${depths[$j]} km, $stage_time Ma ago
END
else
grdimage -V grid${i}"-"${j}".grd" -Yf${yCoor}"c" -Xf${xCoor}"c" -Ccolors.cpt -Rd -JW0/${tot_size} -Ei -O -K >> $output".ps"
pscoast -JW${tot_size} -Rd -W0.9p -Dc -K -O -A0/0/1 >> $output".ps"
stage_time=$(echo -${suffix1[$i]}*$time_step + $time | bc)
pstext -Rd -JW${tot_size} -F+f$font_size"p" -O -K -N -Y-$y_dist"c" -X >> $output".ps" << END
0 0 ${depths[$j]} km, $stage_time Ma ago
END
fi
done
done

temp1=$(echo $(echo "scale = 2; ${#suffix1[@]}/2" | bc) - 1 | bc)
x_center=$(echo $temp1*${x_size} | bc)

colorbar=$(echo $x_size*${#suffix1[@]} | bc)

psscale -D-$x_center"c"/$(echo $y_size + 2.5 | bc)"c"/$colorbar"c"/0.25ch  -Ccolors.cpt -O -S -B$tick_note:"temperature variations [%]":/:: -E >> $output".ps"


ps2pdf $output".ps" $output".pdf"
rm *.grd *.cpt *.ps
okular $output".pdf"
