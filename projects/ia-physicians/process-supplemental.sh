#!/bin/bash
# source `which virtualenvwrapper.sh`
source globals.sh

# echo "- Activating virtualenv"
# workon $PROJECT_NAME


### SUPPLEMENTAL TASKS
echo "- SUPPLEMENTAL TASKS"

echo "- Get just IA physicians"
csvgrep $FILENAME_SUPPLEMENTAL -c Physician_Profile_State -m IA > $CSV_ONE

echo "- Remove unnecessary columns"
csvcut $CSV_ONE -C Physician_Profile_Country_Name,Physician_Profile_Province_Name > $CSV_TWO

echo "- Generating stats"
csvstat $CSV_TWO > output/SUPPLEMENTAL-stats.txt
