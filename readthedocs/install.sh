#!/bin/bash

if [[ ! -d "${DOCS_DIR}" ]]; then
  printf "Documentation source directory '${DOCS_DIR}' does not exist.\n"
  exit 1
fi
if [[ ! -d "${DOCS_DIR}/${REQUIREMENTS_FILE}" ]]; then
  printf "Requirements file '${DOCS_DIR}/${REQUIREMENTS_FILE}' does not exist.\n"
  exit 1
fi
pip install "${DOCS_DIR}/${REQUIREMENTS_FILE}"
