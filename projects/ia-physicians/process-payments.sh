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
	# cp -r json ~/CDR/Templates/branches/Dev/GA/Includes/data/projects/top-paid-doctors
}

# Query the DB
function queryDBResearch() {
	echo "Loop through text file of IDs for research"
	while read id; do
		echo "Getting payments for physician with id $id"
		sqlite3 -header -csv $PROJECT_NAME-RSRCH.db "SELECT Physician_Profile_ID,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_State,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID,Total_Amount_of_Payment_USDollars,Date_of_Payment,Form_of_Payment_or_Transfer_of_Value,Record_ID,Name_of_Associated_Covered_Drug_or_Biological1,Name_of_Associated_Covered_Drug_or_Biological2,Name_of_Study,Research_Information_Link,Context_of_Research FROM data WHERE Physician_Profile_ID = $id ORDER BY CAST(Total_Amount_of_Payment_USDollars AS REAL) DESC;" > output/individual-docs-$id-RSRCH.csv
	done <output/top-physicians-id.txt

	# echo "Copy CSV files to Saxo directory"
	# cp -r output ~/CDR/Templates/branches/Dev/GA/Includes/data/projects/top-paid-doctors

	# Create JSON feeds
	exportJSON
}

# Query the DB
function queryDBGeneral() {
	echo "Loop through text file of IDs for general"
	while read id; do
		echo "Getting payments for physician with id $id"
		sqlite3 -header -csv $PROJECT_NAME-GNRL.db "SELECT Physician_Profile_ID,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_State,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID,Total_Amount_of_Payment_USDollars,Date_of_Payment,Form_of_Payment_or_Transfer_of_Value,Record_ID,Nature_of_Payment_or_Transfer_of_Value,Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value,Name_of_Associated_Covered_Drug_or_Biological1,Name_of_Associated_Covered_Drug_or_Biological2,Contextual_Information FROM data WHERE Physician_Profile_ID = $id ORDER BY CAST(Total_Amount_of_Payment_USDollars AS REAL) DESC;" > output/individual-docs-$id-GNRL.csv
	done <output/top-physicians-id.txt
}

# Query the DB
function queryDB() {
	# echo "Querying most expensive payments"
	# cat sql/most-expensive-payments.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/most-expensive-payments.csv

	echo "Querying most paid docs"
	cat sql/most-paid-docs.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/most-paid-docs.csv
	
	# echo "Querying hospitals with most payments"
	# cat sql/hospitals-most-payments.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/hospitals-most-payments.csv

	# echo "Querying companies with most payments"
	# cat sql/companies-most-payments.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/companies-most-payments.csv

	# echo "Query just DePuy, as they spent the most in Iowa"
	# cat sql/depuy-payments.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/depuy-payments.csv

	# echo "Query top 50 companies and all their payments"
	# cat sql/top-companies-payments.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/top-companies-payments.csv

	echo "Query top 50 doctors and all their payments"
	cat sql/top-doctors-payments.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/top-doctors-payments.csv

	# echo "Query most paid fields of practice"
	# cat sql/fields-most-paid.sql | sqlite3 -header -csv $PROJECT_NAME.db > output/fields-most-paid.csv

	echo "Query most paid docs and only show IDs"
	cat sql/top-physicians-id.sql | sqlite3 $PROJECT_NAME.db > output/top-physicians-id.txt
	
	echo "Loop through text file of IDs"
	while read id; do
		echo "Getting payments for physician with id $id"
		sqlite3 -header -csv $PROJECT_NAME.db "SELECT Physician_Profile_ID,Category,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_State,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID,Total_Amount_of_Payment_USDollars,Date_of_Payment,Category,Record_ID FROM data WHERE Physician_Profile_ID = $id ORDER BY CAST(Total_Amount_of_Payment_USDollars AS REAL) DESC;" > output/individual-docs-$id.csv
	done <output/top-physicians-id.txt

	# echo "Copy CSV files to Saxo directory"
	# cp -r output ~/CDR/Templates/branches/Dev/GA/Includes/data/projects/top-paid-doctors

	# Create JSON feeds
	exportJSON
}

# Create our DB
function createDBTopic() {
	count=1
	for topic in "${TOPIC[@]}"
	do
		echo "${CSV_THREE_TOPIC[$count]}"
		
		# DATABASE TASKS
		echo "DATABASE TASKS: $topic"

		echo "Create table SQL statement: $topic"
		# csvsql -i sqlite ${CSV_THREE_TOPIC[$count]} > sql/data_create_$topic.sql

		echo "Create database: $topic"
		cat sql/data_create_$topic.sql | sqlite3 $PROJECT_NAME-$topic.db
		
		echo "Create table called data with all the data in it: $topic"
		echo ".import ${CSV_THREE_TOPIC[$count]} data" | sqlite3 -csv $PROJECT_NAME-$topic.db

		# With DB created, we'll now query it
		# queryDB

		(( count-- ))

		if [ "$topic" = "GNRL" ]
		then
			echo "Query general sheets"
			queryDBGeneral
		else
			echo "Query research sheets"
			queryDBResearch
		fi
	done
}

# Create our DB
function createDB() {
	# DATABASE TASKS
	echo "DATABASE TASKS"

	echo "Create table SQL statement"
	csvsql -i sqlite $CSV_FOUR > sql/data_create.sql

	echo "Create database"
	cat sql/data_create.sql | sqlite3 $PROJECT_NAME.db
	
	echo "Create table called 'data' with all the data in it"
	echo ".import $CSV_FOUR data" | sqlite3 -csv $PROJECT_NAME.db

	# With DB created, we'll now query it
	queryDB
}

# After we've merged, we have two spreadsheets for each topic
# Let's merge those into one final spreadsheet
function mergeTopics() {
	echo "Combine general and research data"
	csvstack -g "$(echo ${TOPIC[@]} | sed -e 's/ /,/g')" -n "Category" ${CSV_THREES[@]} > $CSV_FOUR

	echo "Generating stats > output/stats.txt"
	csvstat $CSV_FOUR > output/PAYMENTS-stats.txt

	# We're got one spreadsheet so create a DB
	createDB
}

# Merge 2013 and 2014 topic files
function mergeYearsTopic() {
	echo "Combine 2013 and 2014 data: topics"
	csvstack ${CSV_TWOS_TOPIC[@]} > $CSV_THREE_TOPIC
}

function mergeYears() {
	echo "Combine 2013 and 2014 data"
	csvstack ${CSV_TWOS[@]} > $CSV_THREE
}

# Take the raw CSVs and trim them
function trimCSVSResearch() {
	echo "Remove unnecessary columns: research"
	echo "$CSV_ONE > $CSV_TWO_TOPIC"
	csvcut $CSV_ONE -c Covered_Recipient_Type,Teaching_Hospital_ID,Teaching_Hospital_Name,Physician_Profile_ID,Physician_First_Name,Physician_Middle_Name,Physician_Last_Name,Recipient_Primary_Business_Street_Address_Line1,Recipient_Primary_Business_Street_Address_Line2,Recipient_City,Recipient_Zip_Code,Physician_Primary_Type,Physician_Specialty,Submitting_Applicable_Manufacturer_or_Applicable_GPO_Name,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_State,Total_Amount_of_Payment_USDollars,Date_of_Payment,Form_of_Payment_or_Transfer_of_Value,Record_ID,Name_of_Associated_Covered_Drug_or_Biological1,Name_of_Associated_Covered_Drug_or_Biological2,Name_of_Study,Research_Information_Link,Context_of_Research > $CSV_TWO_TOPIC
}

# Take the raw CSVs and trim them
function trimCSVSGeneral() {
	echo "Remove unnecessary columns: general"
	echo "$CSV_ONE > $CSV_TWO_TOPIC"
	csvcut $CSV_ONE -c Covered_Recipient_Type,Teaching_Hospital_ID,Teaching_Hospital_Name,Physician_Profile_ID,Physician_First_Name,Physician_Middle_Name,Physician_Last_Name,Recipient_Primary_Business_Street_Address_Line1,Recipient_Primary_Business_Street_Address_Line2,Recipient_City,Recipient_Zip_Code,Physician_Primary_Type,Physician_Specialty,Submitting_Applicable_Manufacturer_or_Applicable_GPO_Name,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_State,Total_Amount_of_Payment_USDollars,Date_of_Payment,Form_of_Payment_or_Transfer_of_Value,Record_ID,Nature_of_Payment_or_Transfer_of_Value,Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value,Name_of_Associated_Covered_Drug_or_Biological1,Name_of_Associated_Covered_Drug_or_Biological2,Contextual_Information > $CSV_TWO_TOPIC
}

function trimCSVS() {
	# echo "Unzip file"
	# unzip $ZIP_PAYMENTS -d raw/$FOLDER

	# echo "Trim to show just IA physicians"
	# echo "$FILENAME_PAYMENTS > $CSV_ONE"
	# csvgrep $FILENAME_PAYMENTS -c Recipient_State -m IA > $CSV_ONE

	echo "Remove unnecessary columns"
	echo "$CSV_ONE > $CSV_TWO"
	csvcut $CSV_ONE -c Covered_Recipient_Type,Teaching_Hospital_ID,Teaching_Hospital_Name,Physician_Profile_ID,Physician_First_Name,Physician_Middle_Name,Physician_Last_Name,Recipient_Primary_Business_Street_Address_Line1,Recipient_Primary_Business_Street_Address_Line2,Recipient_City,Recipient_Zip_Code,Physician_Primary_Type,Physician_Specialty,Submitting_Applicable_Manufacturer_or_Applicable_GPO_Name,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_State,Total_Amount_of_Payment_USDollars,Date_of_Payment,Form_of_Payment_or_Transfer_of_Value,Record_ID > $CSV_TWO
}

# Create a spreadsheet for each year and each topic
# Using variables in globals.sh
echo "PAYMENTS TASKS"

# Will put our 2013-2014 spreadsheets for each topic in here
# So we can merge into one final spreadsheet
CSV_THREES=()
CSV_THREE_TOPIC=()

# Loop through each topic of data we have (general, research)
for topic in "${TOPIC[@]}"
do
	echo "Loop for $topic"
	
	# This keeps track of our trimmed CSVs for each year
	# So we can merge them later
	CSV_TWOS=()
	CSV_TWOS_TOPIC=()

	# Loop through each year of data we have (2013, 2014)
	for num in "${BEGIN_DATE[@]}"
	do
		echo "Loop for $num"
		
		# Set variables to use within our trimCSVS function
		FILENAME_PAYMENTS="raw/"$FOLDER"/OP_DTL_"$topic"_PGYR"$num"_"$END_DATE".csv"
		ZIP_PAYMENTS="raw/"$FOLDER"/PGYR"${num/20}"_"${END_DATE/20}".ZIP"

		# Path for our first round of CSV files
		CSV_ONE="edits/"$FOLDER/01-"$topic"-ia-"$num".csv
		# Path for our second round of CSV files
		CSV_TWO="edits/"$FOLDER/02-"$topic"-ia-trim-"$num".csv

		# Add this to array so we can merge trimmed CSVs with csvstach
		CSV_TWOS+=($CSV_TWO)

		# Call function and edit our new spreadsheets
		# trimCSVS

		# Do topic specific
		# This allows us to include different columns for each topic
		# Since they are different datasets
		CSV_TWO_TOPIC="edits/"$FOLDER/topic-02-"$topic"-ia-trim-"$num".csv
		CSV_TWOS_TOPIC+=($CSV_TWO_TOPIC)

		# if [ "$topic" = "GNRL" ]
		# then
		# 	echo "Trim general sheets"
		# 	trimCSVSGeneral
		# else
		# 	echo "Trim research sheets"
		# 	trimCSVSResearch
		# fi
	done

	# Denote the years we have merged in the CSV file
	echo "MERGE and DB queries"

	# Turn 2013 2014 BEGIN_DATE variable into 2013-2014
	# For use with CSV variable
	YEARS="$(echo ${BEGIN_DATE[@]} | sed -e 's/ /-/g')"
	# Path for our third round of CSV files
	CSV_THREE="edits/"$FOLDER/03-"$topic"-ia-trim-"$YEARS".csv
	CSV_THREE_TOPIC="edits/"$FOLDER/topic-03-"$topic"-ia-trim-"$YEARS".csv

	# Push to array so we can create on final spreadsheet
	CSV_THREES+=($CSV_THREE)
	CSV_THREE_TOPIC+=($CSV_THREE_TOPIC)

	# Merge 2013 and 2014 spreadsheets into one
	# mergeYears

	# Same only for topic specific sheets
	# mergeYearsTopic
done

# After we've merged, we have two spreadsheets for each topic
# Let's merge those into one final spreadsheet

# Turn GNRL RSRCH TOPIC variable into GNRL-RSRCH
# For use with CSV variable
TOPICS="$(echo ${TOPIC[@]} | sed -e 's/ /-/g')"
CSV_FOUR="edits/"$FOLDER/04-"$TOPICS"-ia-trim-"$YEARS".csv

# Merge topics spreadsheets and call DB tasks
# mergeTopics

# Run just the DB tasks
# createDB
# createDBTopic

# Run just the DB queries
# queryDB
queryDBGeneral
queryDBResearch

# Run just JSON feeds
exportJSON