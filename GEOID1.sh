#!/bin/bash
input=t401.2800.10_03
input2=t401.2800.10_04

output=test.ps


# Setting the region on the map
lon1=-180
lon2=180
lat1=-90
lat2=+90
size=5 

# Projection Style
JX=-JX$(python -c "print 2 *$size")d/$(expr 1 \* $size)d
MW=-JW0/$(python -c "print 2 *$size")d
Projection=$MW

# Interpolation
x_grid_space=2
y_grid_space=2

# GMT color palette
cpt_mode=jet
lower_bound=-50
upper_bound=50
interval=$(expr $(expr $upper_bound - $lower_bound) / 10)



# Conversion of latitude and longitude to GMT grid NETCDF(Prob!) 
xyz2grd $input1 -Ggrid1.grd -R$lon1/$lon2/$lat1/$lat2 -I$x_grid_space/$y_grid_space -V

# Conversion of latitude and longitude to GMT grid NETCDF(Prob!) 
xyz2grd $input2 -Ggrid2.grd -R$lon1/$lon2/$lat1/$lat2 -I$x_grid_space/$y_grid_space -V
#Creating GMT color Palette
makecpt -C$cpt_mode -T$lower_bound/$upper_bound/$interval -Z > colors.cpt
#
# Plot the gridded image
#grdimage -V grid1.grd -Y20c -X30c -Ccolors.cpt -R$lon1/$lon2/$lat1/$lat2 $Projection \
# -E100 -K > $output
#
# Plot the gridded image
grdimage -V grid2.grd -X2c -Y2c -Ccolors.cpt -Rd $Projection -K > $output

## Add the coastline information
pscoast -R$lon1/$lon2/$lat1/$lat2 $Projection -Dc -W1/2/3/3/3 -A10000 \
-N1/1/255/255/255 -O -K >> $output

grdimage -V grid1.grd -X10c -Y2c -Ccolors.cpt -Rd $Projection -O -K >> $output

## Add the coastline information
pscoast -R$lon1/$lon2/$lat1/$lat2 $Projection -Dc -W1/2/3/3/3 -O -A10000 \
-N1/1/255/255/255 -O >> $output

#
## Add a scale bar of the colors
#psscale -D$(expr 1 \* $size)d/$(python -c "print 1.2 *$size")d/$(expr 2 \* $size)d/.6dh -O -Ccolors.cpt -B$interval -O >> $output
#
## Remove the temporary files
##rm colors.cpt grid.grd
#
gv $output
