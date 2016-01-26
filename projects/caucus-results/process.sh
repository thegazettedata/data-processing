#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

function processStatewideData() {
	echo "Process statewide data"
}

function processCountyData() {
	echo "Process county data"
	json2csv -k CountyResults -i $JSON_COUNTY -o $CSV_COUNTY_EDIT_ONE
}

function downloadData() {
	for party in "${PARTIES[@]}"
	do
		echo "- Loop for $party party"
		
		# County, statewide data
		if [ "$TEST" = true ]; then
			JSON_COUNTY="raw_feeds/test/"$party"-counties-test.json"
			JSON_STATEWIDE="raw_feeds/test/"$party"-statewide-test.json"
		else
			JSON_COUNTY="raw_feeds/"$party"-counties.json"
			JSON_STATEWIDE="raw_feeds/"$party"-statewide.json"

			curl -X GET --header "Accept: application/json" "https://www."$party"caucuses.com/api/CountyCandidateResults" > $JSON_COUNTY
			curl -X GET --header "Accept: application/json" "https://www."$party"caucuses.com/api/StateCandidateResults" > $JSON_STATEWIDE
		fi

		CSV_COUNTY_EDIT_ONE="edits/01-"$party"-counties.csv"
		CSV_STATEWIDE_EDIT_ONE="edits/01-"$party"-statewide.csv"

		processCountyData
		processStatewideData

	done
}

downloadData