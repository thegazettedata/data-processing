#Data-processing

This is our working directory of data-processing scripts for projects on The Gazette and KCRG.

With these tasks, we edit csv's, put them into SQLite databases, query them and output new spreadsheets or JSON feeds to use with interactives. The work largely mimics the work done by [Christopher Groskopf](https://github.com/onyxfish), who created this [example project](https://github.com/onyxfish/nicar15-process).

You can view the projects by opening the "projects" folder.

* Note: Raw, unedited spreadsheets and the directory they are in ("raw") are not upload for file size concerns.

##Push to Github
Here's some basic Github commands that you'll need to run to push your projects to Github. First, pull down all changes that have been made to the directory by other people onto your local machine:

	git pull

Then see what you have changed on your local machine:
	
	git status

If you have added files, run:

	git add .
	
If you have added and removed files, run:

	git add --all

Commit any changes you've made:

	git commit -m "message goeshere"

Finally, push all the changes on your local machine to Github:

	git push

Before pushing to Github, make sure to add a link to the chart in [urls.md](https://github.com/GazetteKCRGdata/data-processing/blob/master/urls.md)