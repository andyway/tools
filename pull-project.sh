#!/bin/bash

export USER=alterwin
export HOME=/home/alterwin

REPO_DIR="$HOME/files/$1"
WEB_DIR="$HOME/web/$2/public_html/"


changed_files="$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)"

check_run() {
	echo "$changed_files" | grep --quiet "$1" && eval "$2"
}

if [[  ! -d "${REPO_DIR}" || ! -L "${WEB_DIR}" ]]; then
	echo "---- Entering directory $REPO_DIR ---"
	cd $REPO_DIR

	echo "---------------- Pulling from GitHub ---------------"
	git pull

	# Run `npm install` if package.json changed and `bower install` if `bower.json` changed.
	check_run package.json "npm install"
	check_run bower.json "bower install"

	echo "-------------------- Building ----------------------"
	gulp build

#	rm -rf /home/alterwin/web/beta.alterhaus.com/public_html/*
#	cp -R dist/* /home/alterwin/web/beta.alterhaus.com/public_html/

	echo "--- Rsyncing from "$REPO_DIR/dist/" to $WEB_DIR ---"
	rsync -rtv "$REPO_DIR/dist/" $WEB_DIR
else
	echo "Error: Directory $REPO_DIR does not exist."
fi
