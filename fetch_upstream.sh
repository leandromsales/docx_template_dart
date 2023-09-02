#!/bin/bash

UPSTREAM_URL="git@github.com:PavelS0/docx_template_dart.git"

CURR_DIR=`pwd`
SCRIPT_SYMLINK_DIR=`readlink $0`
if [ "$SCRIPT_SYMLINK_DIR" != "" ];
then
	SCRIPTDIR=$(dirname "$SCRIPT_SYMLINK_DIR")
else
	SCRIPTDIR="$(cd "$(dirname "$0")" && pwd)"
fi

cd "$SCRIPTDIR"

if ! git remote | grep -q '^upstream$'; then
	git remote add upstream $UPSTREAM_URL
fi

git fetch upstream

git checkout master

git merge upstream/master

git push -f origin master

cd ../../..

git add "$SCRIPTDIR"

git commit -m "Updated ${SCRIPTDIR} to latest from original repository"

cd "$CURR_DIR" > /dev/null
