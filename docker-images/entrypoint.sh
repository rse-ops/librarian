#!/bin/bash

set -e


COMMAND="python /code/generate-site.py gen "

# Do we have a dockerfile or a root?
if [ ! -z "${INPUT_DOCKERFILE}" ]; then
    COMMAND="${COMMAND} --dockerfile ${INPUT_DOCKERFILE}"
elif [ ! -z "${INPUT_ROOT}" ]; then
    COMMAND="${COMMAND} --root ${INPUT_ROOT}"
fi

# Output directory?
if [ ! -z "${INPUT_OUTDIR}" ]; then
    COMMAND="${COMMAND} --outdir ${INPUT_OUTDIR}"
fi

# Size in MB?
if [ ! -z "${INPUT_SIZE}" ]; then
    COMMAND="${COMMAND} --size ${INPUT_SIZE}"
fi

COMMAND="${COMMAND} ${INPUT_CONTAINER}"

echo "${COMMAND}"

${COMMAND}
echo $?