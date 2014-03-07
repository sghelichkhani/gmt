#!/bin/bash
input_xyz=geoid_geographical
output=plot.ps

# Setting the region on the map
lon1=-180
lon2=180
lat1=-90
lat2=+90
size=13

# Projection Style
JX=-JX$(python -c "print 2 *$size")d/$(expr 1 \* $size)d
MW=-JW0/$(python -c "print 2 *$size")d
Projection=$MW

# Interpolation
x_grid_space=2
y_grid_space=2

# GMT color palette
cpt_mode=jet
lower_bound=-150
upper_bound=150
interval=$(expr $(expr $upper_bound - $lower_bound) / 10)



# Conversion of latitude and longitude to GMT grid NETCDF(Prob!) 
xyz2grd $input_xyz -Ggrid.grd -R$lon1/$lon2/$lat1/$lat2 -I$x_grid_space/$y_grid_space -V

#Creating GMT color Palette
makecpt -C$cpt_mode -T$lower_bound/$upper_bound/$interval -Z > colors.cpt

# Plot the gridded image
grdimage -V grid.grd -Ccolors.cpt -R$lon1/$lon2/$lat1/$lat2 $Projection \
-B20g10000f10/10g10000nSeW -E300 -K > $output

# Add the coastline information
pscoast -R$lon1/$lon2/$lat1/$lat2 $Projection -Dc -W1/2/3/3/3 -O -K -A10000 \
-N1/1/255/255/255 >> $output

# Add a scale bar of the colors
psscale -D$(expr 1 \* $size)d/$(python -c "print 1.2 *$size")d/$(expr 2 \* $size)d/.6dh -O -Ccolors.cpt -B$interval >> $output

# Remove the temporary files
rm colors.cpt grid.grd

gv $output
