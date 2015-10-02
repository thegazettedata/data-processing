#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

# echo "Activating virtualenv"
# workon $PROJECT_NAME

# Export JSON feeds
function exportJSON() {
	echo "Create JSON file"
	csvjson $CSV_THREE > $JSON_FILE

	echo "Copy JSON feeds to Saxo directory"
	cp -r json ~/CDR_new/Templates/branches/Dev/GA/Includes/data/projects/$PROJECT_NAME
}

# Query the DB
function queryDB() {
	echo "Querying calls under 5:20"
	cat sql/calls-under-520.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/calls-under-520.csv

	echo "Copy CSV files to Saxo directory"
	cp -r output ~/CDR_new/Templates/branches/Dev/GA/Includes/data/projects/$PROJECT_NAME

	# Create JSON feeds
	exportJSON
}


# Create our DB
function createDB() {
	# DATABASE TASKS
	echo "DATABASE TASKS"

	echo "Create table SQL statement"
	csvsql -i sqlite $CSV_THREE > sql/data-create.sql

	echo "Create database"
	cat sql/data-create.sql | sqlite3 $PROJECT_NAME.db
	
	echo "Create table called 'data' with all the data in it"
	echo ".import $CSV_THREE data" | sqlite3 -csv $PROJECT_NAME.db

	# Run created SQL files in newly created database
	queryDB
}

# Convert all Excel files to CSVs
function convertToCSVs() {
	in2csv "raw/cedar rapids 2010-2014.xlsx" > "edits/01-cedarrapids.csv"
	in2csv "raw/Iowa City 2010-2014.xlsx" > "edits/01-iowacity.csv"
	in2csv "raw/2010-2014 marion.xlsx" > "edits/01-marion.csv"
}

function trimCSVs() {
	echo "Remove unnecessary columns"
	csvcut $CSV_ONE -c "Date","year","Address","City","Responsetime","lat","long" > "$CSV_TWO"

	stackCSVs
}

function stackCSVs {
	echo "Stack CSVs into one"
	csvstack "edits/02-cedarrapids-trim.csv" "edits/02-iowacity-trim.csv" "edits/02-marion-trim.csv" > "$CSV_THREE"

	createDB
}

# Create a spreadsheet for each year and each topic
# Using variables in globals.sh
echo "PROCESS THE DATA"

# Convert and trim our spreadsheets
# convertToCSVs

for city in "${CITIES[@]}"
do
	CSV_ONE="edits/01-"$city".csv"
	CSV_TWO="edits/02-"$city"-trim.csv"

	# trimCSVs
done

# Run just the DB tasks
# createDB

# Run just the DB queries
# queryDB

# Run just export JSON
exportJSON