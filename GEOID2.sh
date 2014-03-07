#! /bin/bash

# Path of the main directory of the xyz files
#     (!!) Remember to add '/' in the end
path='/home/sghelichkhani/Workplace/gmt/'
# legacy terra case name
cname=401

# nTH output file in each iteration to be plotted
declare -a suffix1=(00 01 02 03)

# iTH iteration to be plotted
iteration=06
# Km depth to be plotted
declare -a depths=(2800)

## Number of the subplots in total
TotSub=$(echo ${#suffix1[@]}*${#suffix2[@]} | bc)

## Based on the number of the subplots determine the whole size of the plot
Size=2.5

for ((i=0; i<=${#suffix1[@]}-1; ++i )); do
for ((j=0; j<=${#depths[@]}-1; ++j )); do 
echo $i"-"$j;
done
done




