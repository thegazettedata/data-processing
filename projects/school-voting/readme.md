#About this project

To reach these conclusions, The Gazette ran a multi-phase analysis involving four datasets totaling roughly 250,000 records.
 
First, we requested from the Linn County and Johnson County auditors lists of registered voters and whether or not those people voted in the Sept. 10, 2013, school board election.
 
We also asked the Cedar Rapids Community School District and the Iowa City Community School District for lists of their employees in the 2013-2014 school year. We wanted the lists to include the employee’s name, address, position and primary building, but the Cedar Rapids district provided only names.
 
We merged the Linn and Johnson county voter information together into one spreadsheet. We then matched the names in the school employee spreadsheet with all the voter names to see if school employees voted in the last school board election.
 
The technique we used to match names is called deduping, and the program we used is called csvdedupe, which was created by DataMade, a civic technology company based in Chicago, Illinois. All the code that ran this analysis is available on our Github page: https://github.com/GazetteKCRGdata/data-processing.
 
For the Iowa City data, we also received addresses, so we were able to compare not only names but addresses between the voter and salary datasets. This extra criteria likely made the results we found in Iowa City more accurate than the Cedar Rapids analysis.
 
Octav Chipara, a University of Iowa computer science professor familiar with these types of analyses, said matching on names only can render false positives because of common names, such as Ann Smith or John Miller. Because Iowa has less diversity than some states, Iowa names tend to be more similar.
 
“If people had more unique names, you wouldn’t have much of a problem,” he said. “For more common names, you won’t know which ones (are a match).”
 
However, The Gazette attempted to control for this by running a couple of tests. First, we matched Iowa City employees on names only, similar to what was done in Cedar Rapids. The results were very similar: 30 percent voted when we match names and addresses, while 29 pecent voted when we matched names only.

We also ran a second test of the Cedar Rapids data and told the program to match exactly on last names. The result was 15 percent of employees voted, which is the same number we got after we ran our first test.
