#About this project

This shell script downloads data from Census Reporter using [their api](https://github.com/censusreporter/census-api/blob/master/API.md) and merges them all into one JSON file, before merging them with a GeoJSON file. Data includes: Population, poverty rate, median household income and more.

The default geography is Iowa counties but that can be changed in globals.sh. This file is also where you set the Census topics (population, poverty, etc.) you want downloaded and merged.

The [JQ command-line JSON processor](https://stedolan.github.io/jq/) is used to merge the API feeds together into one file.

