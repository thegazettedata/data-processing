#!/bin/bash

PROJECT_NAME="caucus-results"

# Whether or not we want to call APIs or just use test data
TEST=true

# We'll grab data from these parties:
# iagop = Republican party
# idp = Democratic party
PARTIES=("iagop" "idp")

# If you want to download data from just one party, remove one