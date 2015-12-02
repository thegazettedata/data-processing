#!/bin/bash
source globals.sh

# Used when debugging
# Switch to false to make sure data is hampered with
RUN_BLS=true

# BLS API

# Hook up to the 
# Iowa county numbers start with 1
# And ends with 197
# They are all
count_unemployment=0

if [ $RUN_BLS = true ]
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
			echo "- Loop for county number $num"

			# File names
			DIRECTORY_BLS=raw_feeds/BLS_unemployment
			FILE_ONE_BLS=$DIRECTORY_BLS/01-og/01-19"$num"-og.json
			FILE_TWO_BLS=$DIRECTORY_BLS/02-trim/02-19"$num"-trim.json
			FILE_THREE_BLS=edits/01-unemployment.json
			FILE_THREE_BLS_COPY=edits/01-unemployment-copy.json
			
			# Make new directories
			mkdir -p $DIRECTORY_BLS/01-og
			mkdir -p $DIRECTORY_BLS/02-trim

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
    	# curl -X POST -H 'Content-Type: application/json' -d ''$PARAMETERS'' http://api.bls.gov/publicAPI/v2/timeseries/data/ > $FILE_ONE_BLS

    	# Trim out just the unemployment value and wrap in object
    	jq '{ (.["Results"]["series"][0]["seriesID"] | ltrimstr("LAUCN") | rtrimstr("0000000003") ): {"UNEMPLOYMENT": .["Results"]["series"][0]["data"][0]["value"] | tonumber } }' $FILE_ONE_BLS > $FILE_TWO_BLS

    	# jq won't work on blank files
    	# So if it's the first time through the loop
    	# Copy contents of the first trim file into the combined file
    	touch $FILE_THREE_BLS
			touch $FILE_THREE_BLS_COPY
			if [ ! -s $FILE_THREE_BLS ]
			then
				cp $FILE_TWO_BLS $FILE_THREE_BLS
			fi

			# Copy contents of current trim file to combine file so we can get one file with everything
			# We must use a copy file though because jq won't let us copy the combined file with itself
			cp $FILE_THREE_BLS $FILE_THREE_BLS_COPY
    	jq -s '.[0] * .[1]' $FILE_TWO_BLS $FILE_THREE_BLS_COPY > $FILE_THREE_BLS
		fi

		(( count_unemployment++ ))
	done

	# Remove duplicate files
	rm $FILE_THREE_BLS_COPY 
fi