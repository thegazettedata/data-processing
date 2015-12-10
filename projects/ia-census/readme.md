#About this project

This shell script downloads data from Census Reporter using [their API](https://github.com/censusreporter/census-api/blob/master/API.md) and the Bureau of Labor Statistics, using [their API](http://www.bls.gov/developers/home.htm). It then merges all this data into one JSON file, before merging it with a GeoJSON file.

Census data includes: Population, poverty rate, median household income and more. The downloading of the data and merging happens in process-census.sh.

BLS data includes: unemployment. The downloading of the data and merging happens in process-bls.sh.

The default geography is Iowa counties but that can be changed in globals.sh. This file is also where you set the Census topics (population, poverty, etc.) you want downloaded.

The [JQ command-line JSON processor](https://stedolan.github.io/jq/) is used to merge the API feeds together into one file. The file merge-json-geojson.rb is then responsible for merging this with the geojson file of Iowa counties.

Finally, a basic [Leaflet map](https://github.com/Leaflet/Leaflet) is created to make sure the geojson file was created properly. The map is outputs/index.html.

The map includes a slider to hide and show counties based on the Census data we downloaded. The file slider-categories.rb is responsible for creating the file that is used by the slider. It uses the data made available through the APIs.

[LIVE DEMO OF THE MAP](http://thegazettedata.github.io/data-processing/)



