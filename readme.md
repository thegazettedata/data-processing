#Data-processing

This is our working directory of data-processing scripts for projects on The Gazette and KCRG.

With these tasks, we edit csv's, put them into SQLite databases, query them and output new spreadsheets or JSON feeds to use with interactives. The work largely mimics the work done by [Christopher Groskopf](https://github.com/onyxfish), who created this [example project](https://github.com/onyxfish/nicar15-process).

You can view the projects by opening the "projects" folder.

* Note: Raw, unedited spreadsheets and the directory they are in ("raw") are not upload for file size concerns.

##Installation
First you need to make sure a few things are installed on your computer. If you are using a Mac, do the following:

Make sure you have [Homebrew](http://brew.sh/) installed:

	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Install [Node](https://nodejs.org/) via Homebrew:	
	
	brew install node

If you are using a Windows machine, download Node [here](https://nodejs.org/download/).

Install [npm](https://www.npmjs.com/) dependencies:
	
	npm install

We use [Grunt](http://gruntjs.com/) to create new projects and test projects. So make sure it is installed by running:
	
	sudo npm install -g grunt-cli

If you're one Windows machine and are using a PowerShell console, you may want to need add the following [here](https://github.com/gruntjs/grunt/issues/774#issuecomment-58268520)

##Create new project
Dependencies for Grunt are put into package.json. If any new dependencies are put in there, you need to install them by running:
	
	npm install

Then to create a new project, run: 

	grunt new --folder=name_of_folder_here 

The "folder" parameter is equal to the name of the new folder you want to create. All new projects get put into the "projects" folder.

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