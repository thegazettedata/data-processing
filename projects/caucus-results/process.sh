#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

function convertData() {
	echo "Convert data to CSVs"
	rm $CSV_COUNTIES_OUTPUT
	rm $CSV_STATEWIDE_OUTPUT
	ruby scripts/json-to-csv-counties.rb $JSON_COUNTIES $CSV_COUNTIES_OUTPUT
	ruby scripts/json-to-csv-statewide.rb $JSON_STATEWIDE $CSV_STATEWIDE_OUTPUT
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

			curl -X GET --header "Accept: application/json" "https://www."$party"caucuses.com/api/CountyCandidateResults" > $JSON_COUNTIES
			curl -X GET --header "Accept: application/json" "https://www."$party"caucuses.com/api/StateCandidateResults" > $JSON_STATEWIDE
		fi

		CSV_COUNTIES_OUTPUT="output/"$party"-counties.csv"
		CSV_STATEWIDE_OUTPUT="output/"$party"-statewide.csv"

		convertData

	done
}

downloadData