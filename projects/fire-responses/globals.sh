#!/bin/bash

PROJECT_NAME="fire-responses"

# Global filename variables
# This is changed as we run different processes
FOLDER="payments"

# Where the raw data is at
FILENAME="raw/response-times.csv"

CSV_ONE="edits/01-response-times-trim.csv"
CSV_TWO="edits/02-response-times-trim-10-14.csv"
CSV_THREE="edits/03-response-times-building-fires.csv"

CSV_FOUR="output/response-times-cities.csv"
JSON_FILE="json/response-times-cities.json"

URL="URL goes here"
INFO="Info on the project"
