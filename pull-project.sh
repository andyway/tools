#!/bin/bash

export USER=alterwin
export HOME=/home/alterwin

REPO_DIR="~/files/$1"
WEB_DIR="~/web/$2/public_html/"


changed_files="$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)"

check_run() {
	echo "$changed_files" | grep --quiet "$1" && eval "$2"
}

if [ -d "$REPO_DIR" ]; then
	cd $REPO_DIR

	git pull

	# Run `npm install` if package.json changed and `bower install` if `bower.json` changed.
	check_run package.json "npm install"
	check_run bower.json "bower install"

	gulp build

#	rm -rf /home/alterwin/web/beta.alterhaus.com/public_html/*
#	cp -R dist/* /home/alterwin/web/beta.alterhaus.com/public_html/

	rsync -rtv "$REPO_DIR/dist/" $WEB_DIR
else
	echo "Error: Directory $REPO_DIR does not exist."
fi
