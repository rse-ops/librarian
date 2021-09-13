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

# Clone GitHub pages branch with site
git clone -b ${branch} https://github.com/${GITHUB_REPOSITORY} /tmp/repo
cd /tmp/repo
        
git add ${{ env.filename }}

set +e
git status | grep modified
if [ $? -eq 0 ]; then
    set -e
    printf "Changes\n"
    git commit -m "Automated push to update library $(date '+%Y-%m-%d')" || exit 0
    git push origin ${branch}
else
    set -e
    printf "No changes\n"
fi
