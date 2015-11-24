#!/usr/bin/env bash
PROJECT_NAME="ia-census"

# Use the Census Reporter API to download updated Census data
URL="http://api.censusreporter.org/1.0/data/show/latest?table_ids"
IA="04000US19"
COUNTIES="050|04000US19"

# Feed topics
# The first variable is the Census table for each topic
# The second are the specific fields you want to pull
# For instance, most have a "Total" field we use
POPULATION="B01003"
FIELDS_POPULATION=("001")

MEDIAN_AGE="B01002"
FIELDS_MEDIAN_AGE=("001")

MEDIAN_HOUSEHOLD_INCOME="B19013"
FIELDS_MEDIAN_HOUSEHOLD_INCOME=("001")

POVERTY_STATUS="B17001"
FIELDS_POVERTY_STATUS=("001" "002" "003")

UNEMPLOYMENT=""
# http://data.bls.gov/map/MapToolServlet?survey=la&map=county&seasonal=u

# Census topics
TOPICS=("POPULATION" "MEDIAN_AGE" "MEDIAN_HOUSEHOLD_INCOME" "POVERTY_STATUS")
