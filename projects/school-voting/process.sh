#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

# echo "Activating virtualenv"
# workon $PROJECT_NAME

# Query the DB
function queryDB() {
	echo "Show all names that dedupe matched on"
	cat sql/matching-${EMPLOYEE//-names}.sql | sqlite3 -header -csv $DB_EMPLOYEE_TWO > output/matching-$EMPLOYEE.csv

	echo "Show all names that dedupe didn't match on"
	cat sql/not-matching-${EMPLOYEE//-names}.sql | sqlite3 -header -csv $DB_EMPLOYEE_TWO > output/not-matching-$EMPLOYEE.csv

	echo "Find percent of employees who voted"
	cat sql/percent-${EMPLOYEE//-names}.sql | sqlite3 -header -csv $DB_EMPLOYEE_TWO > output/percent-$EMPLOYEE.csv
}

# Create our DB
function createDB() {
	# DATABASE TASKS
	echo "DATABASE TASKS"

	echo "Create table SQL statement"
	csvsql -i sqlite $CSV_FIVE > sql/data-create-$EMPLOYEE-dedupe.sql

	echo "Create database"
	cat sql/data-create-$EMPLOYEE-dedupe.sql | sqlite3 $DB_EMPLOYEE_TWO
	
	echo "Create table called 'data' with all the data in it"
	echo ".import $CSV_FIVE data" | sqlite3 -csv $DB_EMPLOYEE_TWO

	# With DB created, we'll now query it
	# queryDB
}

function dedupeCSVs() {
	echo "Stack Joco and Linn voting data"
	# csvstack ${CSV_THREES[@]} > "$CSV_FOUR"

	echo "Dedupe the voters and $EMPLOYEE employees"
	csvlink $CSV_FOUR $CSV_EMPLOYEES_TWO \
			--config_file=dedupe-config/$EMPLOYEE-config.json \
			--training_file dedupe-training/$EMPLOYEE-employees.json \
			--output_file $CSV_FIVE
}

function trimCSVs() {
	echo "Remove unnecessary columns"
	echo "$CSV_ONE > $CSV_TWO"

	if [ $topic == "joco" ]
	then
		csvcut $CSV_ONE -c REGN_NUM,FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONENO,HOUSE_NUM,HOUSE_SUFFIX,PRE_DIR,STREET_NAME,STREET_TYPE,POST_DIR,UNIT_TYPE,UNIT_NUM,CITY,STATE,ZIP_CODE,VOTERSTATUS,PARTY,GENDER,BIRTHDATE,SCHOOL_ELECTION_DATE_01,SCHOOL_VOTERVOTEMETHOD_01,SCHOOL_ELECTION_DATE_02,SCHOOL_VOTERVOTEMETHOD_02,SCHOOL_ELECTION_DATE_03,SCHOOL_VOTERVOTEMETHOD_03,SCHOOL_ELECTION_DATE_04,SCHOOL_VOTERVOTEMETHOD_04,SCHOOL_ELECTION_DATE_05,SCHOOL_VOTERVOTEMETHOD_05 > $CSV_TWO
	else
		csvcut $CSV_ONE -c REGN_NUM,FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONENO,HOUSE_NUM,HOUSE_SUFFIX,PRE_DIR,STREET_NAME,STREET_TYPE,POST_DIR,UNIT_TYPE,UNIT_NUM,CITY,STATE,ZIP_CODE,VOTERSTATUS,PARTY,GENDER,BIRTHDATE,SCHOOL_ELECTION_091013 > $CSV_TWO
	fi

	echo "Create database so we can concat"
	DB_TOPIC="db/00-$topic.db"

	csvsql -i sqlite $CSV_TWO > sql/data-create-$topic.sql
	cat sql/data-create-$topic.sql | sqlite3 $DB_TOPIC
	echo ".import $CSV_TWO data" | sqlite3 -csv $DB_TOPIC

	echo "Concat addresses and standarize voting records"
	echo "$CSV_TWO > $CSV_THREE"
	cat sql/$topic-concat-addresses.sql | sqlite3 -header -csv $DB_TOPIC > $CSV_THREE
}


function editCSVsLinn() {
	echo "Convert to CSV"
	in2csv "raw/LinnCo voters 8.3.2015.xlsx" > "$CSV_ONE"
}

function editCSVsJoco() {
	echo "Convert to CSV"
	in2csv "raw/JoCo voters Dem 8.3.2015.xlsx" > "edits/00-joco-voters-dems.csv"
	in2csv "raw/JoCo Rep_NP 8.3.2015.xlsx" > "edits/00-joco-voters-rep-np.csv"

	echo "Stack rep, dem voters into one CSV"
	csvstack "edits/00-joco-voters-dems.csv" "edits/00-joco-voters-rep-np.csv" > "$CSV_ONE"
}

# Create a spreadsheet for each topic
# Using variables in globals.sh
echo "PROCESS THE DATA"

# Joco and Linn voting data
CSV_THREES=()

# Loop through each topic of data we have (general, research)
for topic in "${TOPICS[@]}"
do
	echo "- Loop for $topic"

	# Path for CSV file
	TOPIC="$topic"
	CSV_ONE="edits/01-"$topic"-voters.csv"
	CSV_TWO="edits/02-"$topic"-voters-trim.csv"
	CSV_THREE="edits/03-"$topic"-voters-concat.csv"

	CSV_THREES+=($CSV_THREE)

	if [ $topic == "joco" ]
	then
		echo "-"
		# editCSVsJoco
	else
		echo "-"
		# editCSVsLinn
	fi

	# Trim up the CSVs and concat
	trimCSVs
done

# Convert and trim employee data
echo "EMPLOYEE DATA"

# Loop through each city of employee data
for employee in "${EMPLOYEES[@]}"
do
	echo "- Loop for $employee"
	EMPLOYEE="$employee"
	CSV_EMPLOYEES="edits/employees/01-$employee-employees.csv"
	CSV_EMPLOYEES_TWO="edits/employees/02-$employee-employees-uniq.csv"

	echo "Convert employee XLSs to CSVs"
	if [ $employee == "ic" ]
	then
		echo "-"
		in2csv "raw/IC 13-14 wage request.xls" > $CSV_EMPLOYEES
	else
		echo "-"
		in2csv "raw/CR Personnel info 2013 for Gazette.xls" > $CSV_EMPLOYEES
	fi

	echo "Create database so we can query data"
	DB_EMPLOYEE="db/00-$employee-employees.db"

	csvsql -i sqlite $CSV_EMPLOYEES > sql/data-create-$employee.sql
	cat sql/data-create-$employee.sql | sqlite3 $DB_EMPLOYEE
	echo ".import $CSV_EMPLOYEES data" | sqlite3 -csv $DB_EMPLOYEE

	echo "Query unique employees"
	cat sql/$employee-employees-uniq.sql | sqlite3 -header -csv $DB_EMPLOYEE > $CSV_EMPLOYEES_TWO

	# Dedupe the datasets
	CSV_FOUR="edits/04-joco-linn-voters.csv"
	CSV_FIVE="edits/05-$employee-employees-dedupe.csv"

	# Dedupe voters and salary data
	dedupeCSVs

	# Create final DB so we can filter out those who voted
	# And those who didn't
	DB_EMPLOYEE_TWO="db/01-$employee-employees-dedupe.db"

	# Run the DB tasks
	createDB

	# Run the DB queries
	queryDB
done