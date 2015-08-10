#!/bin/bash

export USER="$1"

REPO_DIR="$2"
WEB_DIR="$3"


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
	#check_run package.json "npm install"
	#check_run bower.json "bower install"

	echo "---------------- npm & bower install ---------------"
	npm install
	bower install

	echo "--- Rsyncing from "$REPO_DIR/dist/" to $WEB_DIR ---"
	rsync -rtv "$REPO_DIR/dist/" $WEB_DIR
else
	echo "Error: Directory $REPO_DIR does not exist."
fi
