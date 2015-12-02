#!/bin/bash
source `which virtualenvwrapper.sh`
source globals.sh

# Get Census data
/bin/bash process-census.sh

# Get unemployment data
/bin/bash process-unemployment.sh

# Clean up files in edits directory
# And merge with geojson file of counties

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

# Use this Ruby file to combine geojson file with census, unemployment data
ruby merge-json-geojson.rb $FILE_EDIT_FIVE $FILE_COUNTIES