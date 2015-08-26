#About this project

To reach these conclusions, The Gazette ran a sophisticated analysis involving four datasets that totaled roughly 250,000 rows in all.

The spreadsheets we received were: every registered voter in Linn and Johnson county; and the salaries for every school employee in Iowa City and Cedar Rapids.

We first merged the Linn and Johnson county voter information together into one spreadsheet. We then matched the names in the salary spreadsheet with all the voter names to see if school employees voted in the last election.

For the Iowa City data, we also received addresses, so we were able to compare not only names but addresses between the voter and salary datasets. This extra criteria likely made the results we found in Iowa City more accurate.

The technique we used to match names is called deduping, and the program we used is called csvdedupe, which was created by DataMade, a civic technology company based in Chicago, Illinois.

The program used input by us to help match the names. All the code that ran this analysis is available on our Github page: https://github.com/GazetteKCRGdata/data-processing.