#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

# echo "Activating virtualenv"
# workon $PROJECT_NAME

# Export JSON feeds
function exportJSON() {
	echo "Create JSON feed for every file in CSV folder"
	FILES=output/*.csv

	for file in $FILES
	do
		echo "Converting $file to JSON"
		JSON_FILE="$(echo $file | sed 's/output\///;s/\.csv//')"
		csvjson $file > json/$JSON_FILE.json
	done

	# echo "Copy JSON feeds to Saxo directory"
	# cp -r json ~/CDR_new/Templates/branches/Dev/GA/Includes/data/projects/$PROJECT_NAME
}

# Query the DB
function queryDB() {
	echo "Querying most expensive payments"
	cat sql/most-expensive-payments.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/most-expensive-payments.csv

	echo "Querying most paid docs"
	cat sql/most-paid-docs.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/most-paid-docs.csv

	echo "Query top 50 doctors and all their payments"
	cat sql/top-doctors-payments.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/top-doctors-payments.csv

	# echo "Copy CSV files to Saxo directory"
	# cp -r output ~/CDR_new/Templates/branches/Dev/GA/Includes/data/projects/$PROJECT_NAME

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

	# With DB created, we'll now query it
	queryDB
}

# After we've merged, we have two spreadsheets for each topic
# Let's merge those into one final spreadsheet
function mergeTopics() {
	echo "Combine general and research data"
	csvstack -g "$(echo ${TOPIC[@]} | sed -e 's/ /,/g')" -n "Category" ${CSV_TWOS[@]} > $CSV_THREE

	echo "Generating stats > output/stats.txt"
	csvstat $CSV_THREE > output/stats.txt

	# We're got one spreadsheet so create a DB
	createDB
}

function mergeYears() {
	echo "Combine 2013 and 2014 data"
	csvstack ${CSV_ONES[@]} > $CSV_TWO
}

function trimCSVS() {
	# echo "Trim to show just IA physicians"
	# echo "$FILENAME_PAYMENTS > $CSV_ONE"
	# csvgrep $FILENAME_PAYMENTS -c Recipient_State -m IA > $CSV_ONE

	echo "Remove unnecessary columns"
	echo "$FILENAME > $CSV_ONE"
	csvcut $FILENAME -c Covered_Recipient_Type,Teaching_Hospital_ID,Teaching_Hospital_Name,Physician_Profile_ID,Physician_First_Name,Physician_Middle_Name,Physician_Last_Name,Recipient_Primary_Business_Street_Address_Line1,Recipient_Primary_Business_Street_Address_Line2,Recipient_City,Recipient_Zip_Code,Physician_Primary_Type,Physician_Specialty,Submitting_Applicable_Manufacturer_or_Applicable_GPO_Name,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_State,Total_Amount_of_Payment_USDollars,Date_of_Payment,Form_of_Payment_or_Transfer_of_Value,Record_ID > $CSV_ONE
}

# Create a spreadsheet for each year and each topic
# Using variables in globals.sh
echo "PROCESS THE DATA"

# Will put our 2013-2014 spreadsheets for each topic in here
# So we can merge into one final spreadsheet
CSV_TWOS=()

# Loop through each topic of data we have (general, research)
for topic in "${TOPICS[@]}"
do
	echo "- Loop for $topic"
	
	# This keeps track of our trimmed CSVs for each year
	# So we can merge them later
	CSV_ONES=()

	# Loop through each year of data we have (2013, 2014)
	for num in "${DATE[@]}"
	do
		echo "- Loop for $num"
		
		# Set variables to use within our trimCSVS function
		FILENAME="raw/OP_DTL_"$topic"_PGYR"$num"_P06302015.csv"
		
		# Path for our second round of CSV files
		CSV_ONE="edits/01-"$topic"-ia-trim-"$num".csv"

		# Add this to array so we can merge trimmed CSVs with csvstach
		CSV_ONES+=($CSV_ONE)

		# Call function and edit our new spreadsheets
		trimCSVS
	done

	# Denote the years we have merged in the CSV file
	echo "MERGE and DB queries"

	# Turn 2013 2014 DATE variable into 2013-2014
	# For use with CSV variable
	YEARS="$(echo ${DATE[@]} | sed -e 's/ /-/g')"
	
	# Path for our third round of CSV files
	CSV_TWO="edits/02-"$topic"-ia-trim-"$YEARS".csv"

	# Push to array so we can create on final spreadsheet
	CSV_TWOS+=($CSV_TWO)

	# Merge 2013 and 2014 spreadsheets into one
	mergeYears
done

# After we've merged, we have two spreadsheets for each topic
# Let's merge those into one final spreadsheet

# Turn GNRL RSRCH TOPIC variable into GNRL-RSRCH
# For use with CSV variable
TOPICS="$(echo ${TOPIC[@]} | sed -e 's/ /-/g')"
CSV_THREE="edits/03-"$TOPICS"-ia-trim-"$YEARS".csv"

# Merge topics spreadsheets and call DB tasks
mergeTopics

# Run just the DB tasks
# createDB

# Run just the DB queries
# queryDB

# Run just JSON feeds
# exportJSON