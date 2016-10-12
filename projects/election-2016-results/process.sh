#!/bin/bash

# Download results
curl http://electionresultsiowa.com/xml/20160714_132900.xml > output/election-2016-results.xml

# Parse data
ruby parse.rb

# Upload to FTP server
ruby deploy.rb