#!/usr/bin/env bash
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
mkdir output

echo "Cleaning up old directories"
rm edits/*
rm output/*