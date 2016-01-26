#About this project
These scripts are used to download caucus results from the APIs of each of the state's parties. We will grab all the county data for each race and create CSV files with the data. We use [JQ](https://stedolan.github.io/jq/) to convert the JSON data from the APIs into CSV files.

###APIS
These are the sites we are downloading data from:

[Republican party](https://www.iagopcaucuses.com/swagger/ui/index)
[Democratic party](https://www.idpcaucuses.com/swagger/ui/index)

###Setup
To set up the project, run:

sh setup.sh

###Download
To download the data, run:

sh process.sh

###Testing
There is a TEST variable in globals.sh. If this is set to true, we will convert data that's already been downloaded to your local machine, instead of grabbing it from the APIs. This is ideal if you just want to test the scripts and not actually download the most up-to-date data.
