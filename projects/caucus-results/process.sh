#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

function downloadData() {
	for party in "${PARTIES[@]}"
	do
		echo "- Loop for $party party"
		
		# County data
		curl -X GET --header "Accept: application/json" "https://www."$party"caucuses.com/api/CountyCandidateResults" > raw/$party-counties.json
		# Statewide data
		curl -X GET --header "Accept: application/json" "https://www."$party"caucuses.com/api/StateCandidateResults" > raw/$party-statewide.json

	done
}

downloadData