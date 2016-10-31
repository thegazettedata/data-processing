#!/bin/bash

# Download and parse data
/bin/bash -l -c 'ruby parse.rb'

# Upload to FTP server
/bin/bash -l -c 'ruby deploy.rb'