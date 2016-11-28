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
if [[ " ${params_array[*]} " != *" filter "* ]]; then
	echo "Convert to CSV"
	in2csv "raw/Iowa Boards and Commissions 11.17.2016.xlsx" > edits/01-ia-boards.csv

	echo "Filter columns to include only the Judicial Nominating Commission"
	ruby scripts/filter.rb
fi

if [[ " ${params_array[*]} " != *" count "* ]]; then
	echo "Count members by political party"
	ruby scripts/count.rb

	echo "Convert count CSV to JSON"
	> output/count.json
	echo 'var count = ' >> json/count.json
	csvjson output/count.csv >> json/count.json

	echo "Move JSON file to static-content directory"
	cp json/count.json  ~/Desktop/gazette/github/static-content/projects/ia-boards/json/data.json
fi