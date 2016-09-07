#!/bin/bash
# To run setup:
# sh setup.sh

source `which virtualenvwrapper.sh`
source globals.sh

echo "Creating virtualenv"
mkvirtualenv $PROJECT_NAME

echo "Installing requirements"
pip install -r requirements.txt

echo "Remove DB if exists"
rm $PROJECT_NAME.db