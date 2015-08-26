#!/bin/bash
# To run setup:
# sh setup.sh

source `which virtualenvwrapper.sh`
source globals.sh

echo "Creating virtualenv"
mkvirtualenv $PROJECT_NAME

echo "Installing requirements"
pip install -r requirements.txt

echo "Creating directories"
mkdir edits
mkdir edits/supplemental
mkdir edits/payments
mkdir output

echo "Cleaning up old outputs"
rm edits/*
rm output/*
rm $PROJECT_NAME.db