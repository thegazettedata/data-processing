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

# Download raw data from Google docs
if [[ " ${params_array[*]} " != *" download "* ]]; then
	
	echo "Download raw data"
	for sheet in "${SHEETS[@]}"
	do
		if [[ "${sheet[*]}" == "${SHEETS[0]}" ]]; then
			PARTY="${PARTIES[0]}"
		elif [[ "${sheet[*]}" == "${SHEETS[1]}" ]]; then
			PARTY="${PARTIES[1]}"
		elif [[ "${sheet[*]}" == "${SHEETS[2]}" ]]; then
			PARTY="${PARTIES[2]}"
		elif [[ "${sheet[*]}" == "${SHEETS[3]}" ]]; then
			PARTY="${PARTIES[3]}" 
		fi

		curl "https://docs.google.com/spreadsheets/d/1OMy0HD7URiRF6sNBDY5_ddJpUXktizyc4HaI07w8hV4/export?gid=$sheet&format=csv" > raw/$PARTY.csv
	done
fi

if [[ " ${params_array[*]} " != *" sql "* ]]; then
	
	echo "Remove DB if exists"
	rm $PROJECT_NAME.db

	for party in "${PARTIES[@]}"
	do
		CSV="raw/$party.csv"

		# echo "Create table SQL statement"
		# csvsql -i sqlite --tables "data$party" $CSV > "sql/data-create-$party.sql"

		echo "Add table to database"
		sqlite3 $PROJECT_NAME.db < sql/data-create-$party.sql
		
		echo "Create table called data$party with the data in it"
		echo ".import $CSV data$party" | sqlite3 -csv $PROJECT_NAME.db

		echo "Delete first row"
		echo "Delete from data$party where rowid IN (Select rowid from data$party limit 1);" > sql/delete-first-row.sql
		cat sql/delete-first-row.sql | sqlite3 $PROJECT_NAME.db
	done
fi