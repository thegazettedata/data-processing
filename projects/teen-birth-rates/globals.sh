#!/bin/bash
PROJECT_NAME="teen-birth-rates"

# Use the Census Reporter API to download updated Census data
FEED_URL_COUNTIES="https://api.censusreporter.org/1.0/data/download/latest?table_ids=B01003&geo_ids=04000US19,050|04000US19&format=csv"
FEED_URL_CITIES="https://api.censusreporter.org/1.0/data/download/latest?table_ids=B01003&geo_ids=04000US19,160|04000US19&format=csv"

CENSUS_CODE_COUNTIES="acs2014_5yr_B01003_05000US19049"
CENSUS_CODE_CITIES="acs2014_5yr_B01003_16000US1943950"
