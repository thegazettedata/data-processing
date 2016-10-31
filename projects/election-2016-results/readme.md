#Iowa 2016 election results

This script converts the latest Iowa 2016 election results from the [Secretary of State's office website](http://electionresultsiowa.com/xml/index.html). It first downloads the latest XML file of the results, then converts it into a JSON file, before uploading it to one of four FTP servers. To run:
	
	sh process.sh

If you'd like to just parse through the data and convert, run:

	ruby parse.rb

You can also just deploy the data to your FTP server:

	ruby deploy.rb

Your FTP preferences can be set inside deploy.rb.

Every time the parser is called, a backup copy of the data is saved. You can find these inside the output/old directory. The files are timestamped.

This can all be run as a cronjob:
	
	*/1 * * * * cd ~/<directory> && /bin/bash -l -c 'ruby parse.rb' && /bin/bash -l -c 'ruby deploy.rb' >> ~/<directory>/task.log 2>&1

For instance, on my local machine, the command is:

	*/1 * * * * cd ~/Desktop/gazette/github/data-processing/projects/election-2016-results && /bin/bash -l -c 'ruby parse.rb' && /bin/bash -l -c 'ruby deploy.rb' >> ~/Desktop/gazette/github/data-processing/projects/election-2016-results/task.log 2>&1