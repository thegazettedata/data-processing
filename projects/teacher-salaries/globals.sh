#!/bin/bash

PROJECT_NAME="ia-physicians"

# Global filename variables
# This is changed as we run different processes
FOLDER="payments"

# Topics for supplemental: SPLMTL
# Topics for payments: RSRCH, OWNRSHP, GNRL
TOPIC=("GNRL" "RSRCH")

# Filename variables specific for payments
BEGIN_DATE=("2013" "2014")
END_DATE="P06302015"

# File path for supplemental
FILENAME_SUPPLEMENTAL="raw/"$FOLDER"/OP_PH_PRFL_"$TOPIC"_"$END_DATE".csv"


URL="http://www.cms.gov/OpenPayments/Explore-the-Data/Dataset-Downloads.html"
URL_GNRL_2014="https://openpaymentsdata.cms.gov/dataset/General-Payment-Data-Detailed-Dataset-2014-Reporti/sb72-gakb"

EMAIL="I’ve got a story running on July 26 that will discuss the payments Iowa doctors receive from pharmaceutical and medical device companies. I was hoping we could put together some kind of interactive graphic online to display some of this info?

It’s all CMS data, which looks like it can be downloaded. http://www.cms.gov/OpenPayments/Explore-the-Data/Dataset-Downloads.html

ProPublic has also done a lot on this topic and has state specific data on its site.  https://projects.propublica.org/docdollars/states/IA/

Do you think you have the time to put something together? I was thinking a list of top docs paid, maybe top companies providing the funds, etc. We can talk more about this when you’re in the office this week, too. Give it a look and let me know!"
