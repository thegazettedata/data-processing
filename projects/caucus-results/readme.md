#About this project
These scripts are used to download caucus results from the APIs of each of the state's parties. They grab all the precinct, county and statewide data for each caucus and create CSV files with it. They use [Ruby](https://github.com/ruby/ruby) to convert the JSON data from the APIs into CSV files.

For precinct data, we also convert the data back into a JSON file with several, unneccesary columns trimmed out.

###APIs
These are the sites we are downloading data from:

* [Republican party](https://www.iagopcaucuses.com/swagger/ui/index)
* [Democratic party](https://www.idpcaucuses.com/swagger/ui/index)

###Setup
To set up the project, run:

	sh setup.sh

###Download
To download the data, run:

	sh process.sh

CSVs will be created in the output directory

###Testing
There is a TEST variable in globals.sh. If this is set to true, the scripts will convert the data that's in the raw_feeds/test directory, instead of grabbing it from the APIs. This is ideal if you just want to test the scripts and not actually download the most up-to-date data.
