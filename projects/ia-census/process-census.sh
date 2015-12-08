#!/bin/bash
source globals.sh

# Used when debugging
# Switch to false to make sure data is hampered with
RUN_CENSUS=false

# CENSUS REPORTER API
# Loop through each feed of data we have
count=0

if [ $RUN_CENSUS = true ]
then

	for topic in "${CENSUS_TOPICS[@]}"
	do
		echo "- Loop for $topic"

		# Global vars
		CENSUS_ID="${!topic}"
		FEED_URL="$URL=$CENSUS_ID&geo_ids=$IA,$COUNTIES"
		echo "$FEED_URL"
		TOPIC_CURRENT="${CENSUS_TOPICS[$count]}"
		DIRECTORY=raw_feeds/$CENSUS_ID"_"$topic

		# Get the column numbers for each topic
		# ie for POPULATION, outputs the value of FIELD_POPULATION
		# PLUS the feed value (example: B01003)
		# Because that matches the key in the JSON data
		CURRENT=FIELD_$topic
		FIELD=$CENSUS_ID${!CURRENT}

		# Filenames
		# In the raw directory
		FILE_ONE_1=$DIRECTORY/01-county_ids.json
		FILE_ONE_2=$DIRECTORY/01-data.json
		FILE_TWO=$DIRECTORY/02-combined.json
		FILE_THREE=$DIRECTORY/03-trim.json
		
		# In the edit directory
		FILE_EDIT_ONE=edits/01-census.json
		FILE_EDIT_ONE_COPY=edits/01-census-copy.json
		FILE_EDIT_TWO=edits/02-census-combined.json
		FILE_EDIT_THREE=edits/02-census-no-state.json

		# Make directory for Census topic
		# And download the data from Census Reporter
		# First file is just the counties and their IDs
		# The second is the actual data

		if [ ! -s $FILE_TWO ]
		then
			mkdir $DIRECTORY
			curl "$FEED_URL" | jq ".geography" > $FILE_ONE_1
			curl "$FEED_URL" | jq ".data" > $FILE_ONE_2
			jq -s '.[0] * .[1]' $FILE_ONE_1 $FILE_ONE_2 > $FILE_TWO
		fi

		# This detects whether or not we have a variable that begins with "TOTAL"
		# For this topic. This will tell us if we need to divide the FIELD
		# To get a percentage 
		DIVIDE=DIVIDE_$topic

		# Trim out just the county name and the Census data
		# If we need to divide we will
		if [ ! -s ${!DIVIDE} ]
		then
			FIELD_DIVIDE=$CENSUS_ID${!DIVIDE}
			jq --arg jq_topic $topic --arg jq_census_id $CENSUS_ID --arg jq_FIELD $FIELD --arg jq_divide $FIELD_DIVIDE '[(keys - ["data"])[] as $key | { ($key | ltrimstr("05000US") ): { "county": .[$key]["name"], ($jq_topic): (.[$key][$jq_census_id]["estimate"][$jq_FIELD] / .[$key][$jq_census_id]["estimate"][$jq_divide] * 100) } }] | add' $FILE_TWO > $FILE_THREE
		else
			jq --arg jq_topic $topic --arg jq_census_id $CENSUS_ID --arg jq_FIELD $FIELD '[(keys - ["data"])[] as $key | { ($key | ltrimstr("05000US") ): { "county": .[$key]["name"], ($jq_topic): (.[$key][$jq_census_id]["estimate"][$jq_FIELD]) } }] | add' $FILE_TWO > $FILE_THREE
		fi

		# Remove all files in the edit directoy with the word census in it
		# If it's the first time through this loop
		# This gives us a clean slate when running these operations
		if [ "$count" = "0" ]
		then
			find edits -type f -name \*census\* -exec rm {} \;
		fi

		# Create blank files if the files don't exisit
		# And then fill them with the edit JSON file for this topic
		touch $FILE_EDIT_ONE
		touch $FILE_EDIT_ONE_COPY
		if [ ! -s $FILE_EDIT_ONE ]
		then
			cp $FILE_THREE $FILE_EDIT_ONE
			cp $FILE_THREE $FILE_EDIT_ONE_COPY
		fi

		# Create a final file for Census data
		# And move all the Census data into that file
		# Because we can't copy contents of two files into one of those existing files
		# We create a blank copy of the first JSON file
		jq -s '.[0] * .[1]' $FILE_THREE $FILE_EDIT_ONE_COPY > $FILE_EDIT_ONE
		cp $FILE_EDIT_ONE $FILE_EDIT_ONE_COPY
		jq -s '.[0] * .[1]' $FILE_THREE $FILE_EDIT_ONE_COPY > $FILE_EDIT_TWO

		(( count++ ))
	done

	# Remove duplicate files
	rm $FILE_EDIT_ONE_COPY
	rm $FILE_EDIT_TWO

fi