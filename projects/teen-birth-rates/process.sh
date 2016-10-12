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

if [[ " ${params_array[*]} " != *" raw "* ]]; then
	echo "Download raw data"
	curl -L "$FEED_URL" -o raw/population.zip

	echo "Unzip file"
	7za x raw/population.zip -oraw -aoa

	echo "Rename directory"
	rm -r raw/population
	mv raw/$CENSUS_CODE raw/population
fi

if [[ " ${params_array[*]} " != *" convert "* ]]; then
	echo "Convert to CSV"
	in2csv raw/idph-teen-birth-rates.xlsx > edits/01-convert.csv
fi

if [[ " ${params_array[*]} " != *" reorder "* ]]; then
	echo "Re-order data and add population"
	ruby scripts/reorder.rb
fi

