#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

# We can use parameters to skip certain tasks within this script
# Example:
# sh process.sh --skip=convert

# Pull out parameters and make them an array
# Called params_array
params=$1
prefix="--skip="
param=${params#$prefix}
IFS=', ' read -r -a params_array <<< ${param}

# Download osmfilter so we can 
if [[ " ${params_array[*]} " != *" osmfilter "* ]]; then
	wget -O - http://m.m.i24.cc/osmfilter.c |cc -x c - -O3 -o osmfilter
fi

if [[ " ${params_array[*]} " != *" download "* ]]; then
	# Use wget to download Iowa's layers from OSM
	wget http://download.geofabrik.de/north-america/us/iowa-latest.osm.bz2 -O raw/ia-osm-layers.osm.bz2

	# Unzip bz2 file
	bzip2 -d raw/ia-osm-layers.osm.bz2
fi

# Filter our layers with bridges
if [[ " ${params_array[*]} " != *" bridges "* ]]; then
	./osmfilter raw/ia-osm-layers.osm --keep="bridge=yes" -o=edits/01-ia-bridges.osm
fi