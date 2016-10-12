#Iowa election results

This script will parse through the election 2016 results, which is an XML file from the [Iowa Secretary of State's office](http://electionresultsiowa.com/xml/index.html), convert it into JSON and upload the resulting file to our server. To run:
	
	sh process.sh

If you'd like to just parse through data and convert, run:

	ruby parse.rb