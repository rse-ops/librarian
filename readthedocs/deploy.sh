#!/bin/bash

set -e

# Do we have a dockerfile or a root?
if [ "${INPUT_DEPLOY}" != "true" ]; then
    printf "Deploy is false, will not deploy\n"
    exit 0
fi

printf "GitHub Actor: ${GITHUB_ACTOR}\n"
git config --global user.name "github-actions"
git config --global user.email "github-actions@users.noreply.github.com"

repo_base=$(pwd)

# Clone GitHub pages branch with site
set +e
git clone -b ${branch} https://github.com/${GITHUB_REPOSITORY}.git /tmp/repo || git clone https://github.com/${GITHUB_REPOSITORY}.git /tmp/repo && git checkout -b ${branch}
set -e

# Only move .git history over - everything else re-created
mkdir -p /tmp/git
mv /tmp/repo/.git /tmp/git/.git
rm -rf /tmp/repo
mkdir -p /tmp/repo

# Path to build
html=${repo_base}/${DOCS_DIR}/_build/html
cp -R ${html}/* /tmp/repo/
cd /tmp/repo
mv /tmp/git/.git .git
ls .

git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git add .
git status

set +e
git status | grep -e "modified" -e "new"
if [ $? -eq 0 ]; then
    set -e
    printf "Changes\n"
    git commit -a -m "Automated push to update GitHub pages $(date '+%Y-%m-%d')" || exit 0
    git push origin ${branch} || exit 0
else
    set -e
    printf "No changes\n"
fi
