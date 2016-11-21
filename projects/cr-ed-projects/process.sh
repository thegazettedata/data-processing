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

# Create DB
if [[ " ${params_array[*]} " != *" db "* ]]; then
	CSV='edits/01-ED_Projects_2012-2016.csv'

	echo "Remove DB if exists"
	rm $PROJECT_NAME.db

	echo "Create table SQL statement"
	csvsql -i sqlite --tables "data" $CSV > "sql/data-create.sql"

	echo "Create database"
	cat "sql/data-create.sql" | sqlite3 $PROJECT_NAME.db
	
	echo "Create table called data with data in it"
	echo ".import $CSV data" | sqlite3 -csv -header $PROJECT_NAME.db

	echo "Delete first row"
	cat sql/delete-first-row.sql | sqlite3 -csv $PROJECT_NAME.db
fi

# Query the DB
if [[ " ${params_array[*]} " != *" queries "* ]]; then
	echo "Query: Sum all fields"
	cat sql/sums.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/sums.csv

	echo "Query: Sum by year"
	cat sql/yearly-sums.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/yearly-sums.csv
fi

# Create HTML table
if [[ " ${params_array[*]} " != *" html "* ]]; then
	echo "Sort and trim CSV"
	python scripts/sort.py

	echo ""
	
fi