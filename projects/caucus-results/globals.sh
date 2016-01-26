#!/bin/bash

PROJECT_NAME="caucus-results"

# Check for whether or not we want to call API
# or use test data
TEST=false

# We'll grab data from these parties
# iagop = Republican party
# idp = Democratic party
PARTIES=("iagop" "idp")