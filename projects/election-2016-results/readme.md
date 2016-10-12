#Iowa 2016 election results

This script converts the latest Iowa 2016 election results from the [Secretary of State's office website](http://electionresultsiowa.com/xml/index.html). It first downloads the latest XML file of the results, then converts it into a JSON file, before uploading it to one of four FTP servers. To run:
	
	sh process.sh

If you'd like to just parse through the data and convert, run:

	ruby parse.rb