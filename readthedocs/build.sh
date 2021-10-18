#!/bin/bash

if [[ ! -d "${DOCS_DIR}" ]]; then
  printf "Documentation source directory '${DOCS_DIR}' does not exist.\n"
  exit 1
fi

cd ${DOCS_DIR}
make html
