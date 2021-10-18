#!/bin/bash

DOCS_DIR=$(realpath ${DOCS_DIR})
printf "Documentation directory is ${DOCS_DIR}\n"
if [[ ! -d "${DOCS_DIR}" ]]; then
  printf "Documentation source directory '${DOCS_DIR}' does not exist.\n"
  exit 1
fi
if [[ ! -f "${DOCS_DIR}/${REQUIREMENTS_FILE}" ]]; then
  printf "Requirements file '${DOCS_DIR}/${REQUIREMENTS_FILE}' does not exist.\n"
  exit 1
fi
pip install -r "${DOCS_DIR}/${REQUIREMENTS_FILE}"
