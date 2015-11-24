#About this project

This shell script downloads data from Census Reporter using [their api](https://github.com/censusreporter/census-api/blob/master/API.md) and merges it all into on JSON file, before merging them with a GeoJSON file. The default geography is Iowa counties but that can be changed in globals.sh. This file is also where you set the Census topics (population, poverty, etc.) you want downloaded and merged.

