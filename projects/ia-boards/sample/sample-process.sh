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

# Convert XLS into CSV
# Can skip with the 'convert' param
if [[ " ${params_array[*]} " != *" convert "* ]]; then
	mkdir raw/csv

	for year in "${YEARS[@]}"
	do
		echo "- Converting for $year"
		in2csv 'raw/'$year' city owned parcels.xls' > 'raw/csv/'$year'-parcels.csv'
		in2csv 'raw/'$year' valuations.xls' > 'raw/csv/'$year'-valuations.csv'
	done
fi

# Merge parcel, valuations CSVs into one for each year
# Can skip with the 'merge' param
if [[ " ${params_array[*]} " != *" merge "* ]]; then
	# echo '- Convert column names'
	# python scripts/01-convert-column-names.py

	for year in "${YEARS[@]}"
	do
		CSV_ONE_PARCELS='edits/01-'$year'-parcels-rename.csv'
		CSV_ONE_VALUATIONS='edits/01-'$year'-valuations-rename.csv'
		CSV_TWO='edits/02-'$year'-parcels-2016-valuations.csv'
		CSV_VALUATIONS_2008='edits/01-2008-valuations-rename.csv'
		CSV_VALUATIONS_2016='edits/01-2016-valuations-rename.csv'
		CSV_THREE='edits/03-'$year'-parcels-2008-valuations.csv'
		CSV_FOUR='edits/04-'$year'-parcels-2008-2016-valuations.csv'
		CSV_FIVE='edits/05-'$year'-parcels-2008-2016-valuations-trim.csv'
		CSV_SIX='edits/06-'$year'-parcels-2008-2016-valuations-trim.csv'

		echo "- Merge parcels and valuations data for $year"
		csvjoin -c 'GIS_Number,GIS_Number_valuations' $CSV_ONE_PARCELS $CSV_ONE_VALUATIONS | csvcut -C 'GIS_Number_valuations,GIS_Number_2,Map_Name_valuations,Class_valuations' > $CSV_TWO

		echo "- Get 2008 valuations for $year"
		csvjoin -c 'GIS_Number,GIS_Number_valuations' --left $CSV_TWO $CSV_VALUATIONS_2008 > $CSV_THREE

		echo "- Get 2016 valuations for $year"
		csvjoin -c 'GIS_Number,GIS_Number_valuations' --left $CSV_THREE $CSV_VALUATIONS_2016 > $CSV_FOUR
		
		echo "- Trim excessive columns for $year"
		if [[ "$year" = "2008" ]]; then
			csvcut -C "GIS_Number_valuations,Map_Name_valuations,Class_valuations,2008 Land,2008 Dwlg,2008 Improv,2008 total" $CSV_FOUR > $CSV_FIVE
		elif [[ "$year" = "2016" ]]; then
			csvcut -C "GIS_Number_valuations,Map_Name_valuations,Class_valuations,2016 Land Res,2016 Land Comm,2016 Land Total,2016 Dwlg,2016 Improv,2016 Total" $CSV_FOUR > $CSV_FIVE
		else
			csvcut -C 'GIS_Number_valuations,Map_Name_valuations,Class_valuations' $CSV_FOUR > $CSV_FIVE
		fi
		csvcut -C 'GIS_Number_valuations,Map_Name_valuations,Class_valuations' $CSV_FIVE > $CSV_SIX
	done
fi

# Create DB
# Can skip with the 'db' param
if [[ " ${params_array[*]} " != *" db "* ]]; then
	echo "- Remove old DB"
	rm $PROJECT_NAME.db

	for year in "${YEARS[@]}"
	do
		CSV_SIX='edits/06-'$year'-parcels-2008-2016-valuations-trim.csv'

		echo "- Create table SQL statement"
		csvsql -i sqlite --tables "data"$year $CSV_SIX > "sql/data-create-"$year".sql"

		echo "- Create database"
		cat "sql/data-create-"$year".sql" | sqlite3 $PROJECT_NAME.db
	
		echo "- Create table called data$year with the $year data in it"
		echo ".import $CSV_SIX data"$year | sqlite3 -csv -header $PROJECT_NAME.db

		echo "Delete first row"
		echo "Delete from data$year where rowid IN (Select rowid from data$year limit 1);" > sql/delete-first-row.sql
		cat sql/delete-first-row.sql | sqlite3 -csv $PROJECT_NAME.db
	done
fi

if [[ " ${params_array[*]} " != *" query "* ]]; then
	echo "- Query DB"

	echo "Find 2016, 2013 properties city owned in 2008"
	cat sql/2016-properties-in-2008.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/2016-properties-in-2008.csv
	cat sql/2013-properties-in-2008.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/2013-properties-in-2008.csv

	echo "Find 2016, 2013 properties city didn't own in 2008"
	cat sql/2016-properties-not-in-2008.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/2016-properties-not-in-2008.csv
	cat sql/2013-properties-not-in-2008.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/2013-properties-not-in-2008.csv

	echo "Find 2013 properties city didn't own in 2016"
	cat sql/2013-properties-not-in-2016.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/2013-properties-not-in-2016.csv

	echo "Find 2008-2016 properties"
	cat sql/2008-2016-properties.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/2008-2016-properties.csv

	echo "Find 2008-2016 acres"
	cat sql/2008-2016-acres.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/2008-2016-acres.csv

	echo "Find 2008-2016 total assessed values"
	cat sql/2008-2016-total-assessed-values.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/2008-2016-total-assessed-values.csv
fi