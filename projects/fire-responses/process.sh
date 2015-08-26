#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

# echo "Activating virtualenv"
# workon $PROJECT_NAME

# Export JSON feeds
function exportJSON() {
	# echo "Create JSON feed for every file in CSV folder"
	# csvjson $CSV_FOUR > $JSON_FILE

	echo "Copy JSON feeds to Saxo directory"
	cp -r json ~/CDR/Templates/branches/Dev/GA/Includes/data/projects/$PROJECT_NAME
}

# Query the DB
function queryDB() {
	# echo "Query total calls under 7 minutes for each department"
	# cat sql/calls-under-7.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/calls-under-7.csv

	echo "Copy CSV files to Saxo directory"
	cp -r output ~/CDR/Templates/branches/Dev/GA/Includes/data/projects/$PROJECT_NAME

	# Create JSON feeds
	exportJSON
}

# Create our DB
function createDB() {
	# DATABASE TASKS
	echo "DATABASE TASKS"

	echo "Create table SQL statement"
	csvsql -i sqlite $CSV_ONE > sql/data-create.sql

	echo "Create database"
	cat sql/data-create.sql | sqlite3 $PROJECT_NAME.db
	
	echo "Create table called 'data' with all the data in it"
	echo ".import $CSV_ONE data" | sqlite3 -csv $PROJECT_NAME.db

	# Create CSV files for each town in the DB
	# queryDB
}

function trimCSVS() {
	echo "Remove unnecessary columns"
	echo "$FILENAME > $CSV_ONE"
	csvcut $FILENAME -c "Service Name",time_diff_edit,"Incident Date",Year,"Full Address","Fire Incident Type",lat,long > $CSV_ONE

	echo "Get just 2010 through 2014 data"
	csvgrep $CSV_ONE -c Year -r "[2][0][1]+" > $CSV_TWO

	echo "Get just building fires"
	csvgrep $CSV_TWO -c "Fire Incident Type" -m "Building fire" > $CSV_THREE

	echo "Filter out cities"
	csvgrep $CSV_THREE -c "Service Name" -f "edits/depts.txt" > $CSV_FOUR
	
	# Create the database
	# createDB
}

# Create a spreadsheet for each year and each topic
# Using variables in globals.sh
echo "PROCESS THE DATA"

# Call function and edit our new spreadsheets
# trimCSVS

# Run just the DB tasks
# createDB
queryDB

# Run just export JSON
# exportJSON

# Run just JSON feeds
# exportJSON