#!/usr/bin/env bash
# source `which virtualenvwrapper.sh`
source globals.sh

# Used when debugging
# Switch to false to make sure data is hampered with
RUN=true

# Loop through each feed of data we have
count=0

echo "Bash version ${BASH_VERSION}..."

for topic in "${TOPICS[@]}"
do
	# Global vars
	CENSUS_ID="${!topic}"
	FEED_URL="$URL=$CENSUS_ID&geo_ids=$IA,$COUNTIES"
	TOPIC_CURRENT="${TOPICS[$count]}"
	DIRECTORY=raw_feeds/$CENSUS_ID"_"$topic
	echo "- Loop for $topic"

	# Get the column numbers for each topic
	# ie for POPULATION, outputs the value of FIELDS_POPULATION
	# PLUS the feed value (example: B01003)
	# Because that matches the key in the JSON data
	CURRENT=FIELDS_$topic
	echo $CURRENT
	FIELDS=$CENSUS_ID${!CURRENT}
	echo $FIELDS
	echo "${!CURRENT[@]}"

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

	# Make directory for Census topic
	# And download the data from Census Reporter
	# First file is just the counties and their IDs
	# The second is the actual data
	if [ run = true ]
	then
		echo "Running"

		if [ ! -s $FILE_TWO ]
		then
			mkdir $DIRECTORY
			curl "$FEED_URL" | jq ".geography" > $FILE_ONE_1
			curl "$FEED_URL" | jq ".data" > $FILE_ONE_2
			jq -s '.[0] * .[1]' $FILE_ONE_1 $FILE_ONE_2 > $FILE_TWO
		fi

		# Trim out just the county name and the Census data
		jq --arg jq_topic $topic --arg jq_census_id $CENSUS_ID --arg jq_FIELDS $FIELDS '[.[] as $obj | { ($obj["name"]): { ($jq_topic): ($obj[$jq_census_id]["estimate"][$jq_FIELDS]) } } ] | add' $FILE_TWO > $FILE_THREE

		# Clear out edits directory if it's the first time through this loop
		if [ "$count" = "0" ]
		then
			rm edits/*
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
	fi

	(( count++ ))
done