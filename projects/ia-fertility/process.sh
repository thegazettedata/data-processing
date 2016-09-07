#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

# We can use parameters to skip certain tasks within this script
# Example:
# sh process.sh --skip=convert

# Pull out parameters and make them an array
# Called params_array
params=$1
prefix="--skip="
param=${params#$prefix}
IFS=', ' read -r -a params_array <<< ${param}

# Can skip with the 'convert' param
if [[ " ${params_array[*]} " != *" cut "* ]]; then
	echo "Cutting out unnecessary columns"
	csvcut -c 1,3,4,5,6,7,10,11,14,15,16,17,18,19,20,21,22,23 raw/ACS_14_5YR_S1301/ACS_14_5YR_S1301.csv > edits/01-cut.csv
fi