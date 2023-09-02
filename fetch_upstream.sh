#!/bin/bash

PAVEL_REMOTE_ORIGIN="upstream"
PAVEL_URL="git@github.com:PavelS0/docx_template_dart.git"
ALEXANDRE_REMOTE_ORIGIN="alexandre"
ALEXANDRE_URL="git@github.com:AlexandreMaillot/docx_template_dart.git"

add_remote_origin() {
	name=$1
	url=$2
	if ! git remote | grep -q "^${name}$"; then
		git remote add upstream $url
	fi
}

CURR_DIR=`pwd`
SCRIPT_SYMLINK_DIR=`readlink $0`
if [ "$SCRIPT_SYMLINK_DIR" != "" ];
then
	SCRIPTDIR=$(dirname "$SCRIPT_SYMLINK_DIR")
else
	SCRIPTDIR="$(cd "$(dirname "$0")" && pwd)"
fi

cd "$SCRIPTDIR"

if command -v tac &>/dev/null; then
    REVERSE_CMD="tac"
elif command -v tail &>/dev/null; then
    REVERSE_CMD="tail -r"
else
    echo "Neither tac nor tail is available. Exiting."
    exit 1
fi

add_remote_origin $PAVEL_REMOTE_ORIGIN $PAVEL_URL
git fetch $PAVEL_REMOTE_ORIGIN

add_remote_origin $ALEXANDRE_REMOTE_ORIGIN $ALEXANDRE_URL
git fetch $ALEXANDRE_REMOTE_ORIGIN

git config --global pager.log false

git stash

git checkout master

git merge upstream/master

git merge alexandre/master

(git log --pretty=format:"%H" ${PAVEL_REMOTE_ORIGIN}/master..${ALEXANDRE_REMOTE_ORIGIN}/master; echo "") | while read commit; do
	if [ ! -z "$commit" ]; then
		if ! git merge-base --is-ancestor $commit HEAD; then
			echo "Cherrying pick commit $commit"
			git cherry-pick $commit
		fi
	fi
done

git push -f origin master

cd ../../..

git add "$SCRIPTDIR"

git commit -m "Updated ${SCRIPTDIR} to latest from original repository"

cd "$CURR_DIR" > /dev/null

git stash pop
