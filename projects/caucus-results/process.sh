#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

function convertData() {
	# echo "Remove old directories"
	# rm $CSV_COUNTIES_OUTPUT
	# rm $CSV_STATEWIDE_OUTPUT
	rm $CSV_PRECINCTS_OUTPUT
	
	# echo "Convert data to CSVs"
	# ruby scripts/json-to-csv-counties.rb $JSON_COUNTIES $CSV_COUNTIES_OUTPUT $party
	# ruby scripts/json-to-csv-statewide.rb $JSON_STATEWIDE $CSV_STATEWIDE_OUTPUT $party
	ruby scripts/json-to-csv-precincts.rb $JSON_PRECINCTS $CSV_PRECINCTS_OUTPUT $party

	# echo "Convert precinct data to JSON"
	csvjson $CSV_PRECINCTS_OUTPUT > json/"$party"-precincts.json

	# echo "Minify precinct JSON files"
	ruby scripts/minify-json.rb json/"$party"-precincts.json
}

function downloadData() {
	for party in "${PARTIES[@]}"
	do
		echo "- Loop for $party party"
		
		# COUNTIES, statewide data
		if [ "$TEST" = true ]; then
			JSON_COUNTIES="raw_feeds/test/"$party"-counties.json"
			JSON_STATEWIDE="raw_feeds/test/"$party"-statewide.json"
			JSON_PRECINCTS="raw_feeds/test/"$party"-precincts.json"
		else
			JSON_COUNTIES="raw_feeds/"$party"-counties.json"
			JSON_STATEWIDE="raw_feeds/"$party"-statewide.json"
			JSON_PRECINCTS="raw_feeds/"$party"-precincts.json"

			curl -X GET --header "Accept: application/json" "https://www."$party"caucuses.com/api/CountyCandidateResults" > $JSON_COUNTIES
			curl -X GET --header "Accept: application/json" "https://www."$party"caucuses.com/api/StateCandidateResults" > $JSON_STATEWIDE
			curl -X GET --header "Accept: application/json" "https://www."$party"caucuses.com/api/PrecinctCandidateResults" > $JSON_PRECINCTS
		fi

		CSV_COUNTIES_OUTPUT="output/"$party"-counties.csv"
		CSV_STATEWIDE_OUTPUT="output/"$party"-statewide.csv"
		CSV_PRECINCTS_OUTPUT="output/"$party"-precincts.csv"

		convertData

	done
}

downloadData