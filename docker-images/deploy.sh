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
git config --global pull.rebase true

# Clone GitHub pages branch with site
git clone -b ${branch} https://github.com/${GITHUB_REPOSITORY}.git /tmp/repo
cd /tmp/repo
ls .

# If no output directory defined, use PWD
if [ -z "${INPUT_OUTDIR+x}" ]; then 
    printf "No outdir defined, will use $PWD.\n"
    INPUT_OUTDIR=$PWD
else
    printf "Outdir defined to be $INPUT_OUTDIR.\n"
fi

printf "Markdown file generated was ${filename}\n"
filebase=$(basename $filename)
cp ${filename} ${INPUT_OUTDIR}/${filebase}

git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git add ${INPUT_OUTDIR}/${filebase}
git status

set +e
git status | grep -e "modified" -e "new"
if [ $? -eq 0 ]; then
    set -e
    printf "Changes\n"
    # Typically changes are just timestamps, so it's okay for an occasional merge conflict that fails
    git commit -m "Automated push to update library $(date '+%Y-%m-%d')" || exit 0

    # Keep trying until we are successful
    while ! git push origin ${branch}
        do
            echo "Trying again..."
            sleep $[ ( $RANDOM % 10 )  + 1 ]s
            git pull origin ${branch}
        done             
else
    set -e
    printf "No changes\n"
fi
