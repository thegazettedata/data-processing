#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

# Used when debugging
# Switch to false to make sure data is hampered with
RUN_TOPICS=false
RUN_UNEMPLOYMENT=false

# CENSUS REPORTER API
# Loop through each feed of data we have
count=0

if [ $RUN_TOPICS = true ]
then

	for topic in "${TOPICS[@]}"
	do
		echo "- Loop for $topic"

		# Global vars
		CENSUS_ID="${!topic}"
		FEED_URL="$URL=$CENSUS_ID&geo_ids=$IA,$COUNTIES"
		echo "$FEED_URL"
		TOPIC_CURRENT="${TOPICS[$count]}"
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

# BLS API

# Hook up to the 
# Iowa county numbers start with 1
# And ends with 197
# They are all
count_unemployment=0

if [ $RUN_UNEMPLOYMENT = true ]
then

	for num in $(seq 1 197)
	do
		# Find odd numbers
		if [ $(($num%2)) -eq 1 ];
		then
			# All digits need to be at three digits
			# So 7 is converted to 007
			if [ $num -lt 10 ]
			then
				num="00"$num
			elif [ $num -lt 100 ]
			then
				num="0"$num
			fi

			# File names
			DIRECTORY_UNEMPLOYMENT=raw_feeds/BLS_unemployment
			FILE_ONE_UNEMPLOYMENT=$DIRECTORY_UNEMPLOYMENT/01-og/01-19"$num"-og.json
			FILE_TWO_UNEMPLOYMENT=$DIRECTORY_UNEMPLOYMENT/02-trim/02-19"$num"-trim.json
			FILE_THREE_UNEMPLOYMENT=edits/01-unemployment.json
			FILE_THREE_UNEMPLOYMENT_COPY=edits/01-unemployment-copy.json
			
			# Make new directories
			mkdir -p $DIRECTORY_UNEMPLOYMENT/01-og
			mkdir -p $DIRECTORY_UNEMPLOYMENT/02-trim

			# Remove all files in the edits directoy with the word unemployment in it
			# If it's the first time through this loop
			if [ "$count_unemployment" = "0" ]
			then
				find edits -type f -name \*unemployment\* -exec rm {} \;
			fi

			# Curl request the BLS API
			# Requires registration key
			echo "http://api.bls.gov/publicAPI/v2/timeseries/data/LAUCN19"${num}"0000000003"
			ID="LAUCN19"${num}"0000000003"
    	PARAMETERS='{"seriesid":["'${ID}'"],"registrationKey":"4e7c7817ef4949c29a604cf131cca7c4"}'
    	# curl -X POST -H 'Content-Type: application/json' -d ''$PARAMETERS'' http://api.bls.gov/publicAPI/v2/timeseries/data/ > $FILE_ONE_UNEMPLOYMENT

    	# Trim out just the unemployment value and wrap in object
    	jq '{ (.["Results"]["series"][0]["seriesID"] | ltrimstr("LAUCN") | rtrimstr("0000000003") ): {"UNEMPLOYMENT": .["Results"]["series"][0]["data"][0]["value"] | tonumber } }' $FILE_ONE_UNEMPLOYMENT > $FILE_TWO_UNEMPLOYMENT

    	# jq won't work on blank files
    	# So if it's the first time through the loop
    	# Copy contents of the first trim file into the combined file
    	touch $FILE_THREE_UNEMPLOYMENT
			touch $FILE_THREE_UNEMPLOYMENT_COPY
			if [ ! -s $FILE_THREE_UNEMPLOYMENT ]
			then
				cp $FILE_TWO_UNEMPLOYMENT $FILE_THREE_UNEMPLOYMENT
			fi

			# Copy contents of current trim file to combine file so we can get one file with everything
			# We must use a copy file though because jq won't let us copy the combined file with itself
			cp $FILE_THREE_UNEMPLOYMENT $FILE_THREE_UNEMPLOYMENT_COPY
    	jq -s '.[0] * .[1]' $FILE_TWO_UNEMPLOYMENT $FILE_THREE_UNEMPLOYMENT_COPY > $FILE_THREE_UNEMPLOYMENT
		fi

		(( count_unemployment++ ))
	done

	# Remove duplicate files
	rm $FILE_THREE_UNEMPLOYMENT_COPY 
fi


# Final filenames
FILE_EDIT_FOUR=edits/02-census-unemployment.json
FILE_EDIT_FIVE=edits/03-census-unemployment-geoid.json
FILE_COUNTIES=raw_feeds/ia-counties.json

# This creates the final edit file with Census and unemployment data
jq -s '.[0] * .[1]' edits/01-census.json edits/01-unemployment.json > $FILE_EDIT_FOUR
jq 'with_entries(.key |= "05000US" + .)' $FILE_EDIT_FOUR > $FILE_EDIT_FIVE

# Download geojson file
if [ ! -s $FILE_COUNTIES ]
then
	curl http://catalog.civicdashboards.com/dataset/68325db8-6eb5-4b38-a982-82fc9eafb669/resource/52b6d8b4-b203-4ab3-94db-e5e93c335a14/download/08b992e5409d442eb0ce16c481c12818temp.geojson > $FILE_COUNTIES
fi

# Combine geojson file with census, unemployment data
# jq -s '.[1] as $prop | $prop[]' $FILE_COUNTIES $FILE_EDIT_FIVE
# jq -s '.[0] as $object | keys  ' $FILE_EDIT_FIVE $FILE_COUNTIES

ruby merge-json-geojson.rb $FILE_EDIT_FIVE $FILE_COUNTIES