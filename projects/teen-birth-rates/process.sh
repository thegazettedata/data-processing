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

# COUNTIES
if [[ " ${params_array[*]} " != *" counties "* ]]; then
	echo "Counties: Download raw data"
	curl -L "$FEED_URL_COUNTIES" -o raw/population-counties.zip

	echo "Unzip file"
	7za x raw/population-counties.zip -oraw -aoa

	echo "Rename directory"
	rm -r raw/population-counties
	mv raw/$CENSUS_CODE_COUNTIES raw/population-counties

	echo "Convert county rates to CSV"
	in2csv raw/idph-teen-birth-rates.xlsx > edits/01-counties-rates.csv

	echo "Counties: Merge teen birth rates and population"
	ruby scripts/merge-counties.rb
fi

# CITIES
if [[ " ${params_array[*]} " != *" cities "* ]]; then
	echo "Cities: Download raw data"
	curl -L "$FEED_URL_CITIES" -o raw/population-cities.zip

	echo "Unzip file"
	7za x raw/population-cities.zip -oraw -aoa

	echo "Rename directory"
	rm -r raw/population-cities
	mv raw/$CENSUS_CODE_CITIES raw/population-cities

	echo "Cities: Merge teen birth rates and population"
	ruby scripts/merge-cities.rb
fi

# CASEY'S
if [[ " ${params_array[*]} " != *" caseys "* ]]; then
	echo "Convert Casey's Excel file to CSV"
	in2csv "raw/Casey's Locations and other information.xlsx" > edits/03-caseys.csv

	echo "Geocode Casey's addresses"
	python scripts/geocoder.py "03-caseys" "Casey's Location"


	echo "Rename columns"
	python scripts/rename-columns-caseys.py

	echo "Convert CSV to JSON"
	csvjson edits/04-caseys-rename-geo.csv > map/caseys.json
fi