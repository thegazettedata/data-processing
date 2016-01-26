#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

function convertData() {
	echo "Convert data to CSVs"
	rm $CSV_COUNTIES_EDIT_ONE
	rm $CSV_STATEWIDE_EDIT_ONE
	ruby json-to-csv-counties.rb $JSON_COUNTIES $CSV_COUNTIES_EDIT_ONE
	ruby json-to-csv-statewide.rb $JSON_STATEWIDE $CSV_STATEWIDE_EDIT_ONE
}

function downloadData() {
	for party in "${PARTIES[@]}"
	do
		echo "- Loop for $party party"
		
		# COUNTIES, statewide data
		if [ "$TEST" = true ]; then
			JSON_COUNTIES="raw_feeds/test/"$party"-counties-test.json"
			JSON_STATEWIDE="raw_feeds/test/"$party"-statewide-test.json"
		else
			JSON_COUNTIES="raw_feeds/"$party"-counties.json"
			JSON_STATEWIDE="raw_feeds/"$party"-statewide.json"

			curl -X GET --header "Accept: application/json" "https://www."$party"caucuses.com/api/COUNTIESCandidateResults" > $JSON_COUNTIES
			curl -X GET --header "Accept: application/json" "https://www."$party"caucuses.com/api/StateCandidateResults" > $JSON_STATEWIDE
		fi

		CSV_COUNTIES_EDIT_ONE="edits/01-"$party"-counties.csv"
		CSV_STATEWIDE_EDIT_ONE="edits/01-"$party"-statewide.csv"

		convertData

	done
}

downloadData