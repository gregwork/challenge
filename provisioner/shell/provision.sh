#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

function check_user {
  if [[ ${EUID} -ne 0 ]]; then
    >2 echo "This script requires root; please re-execute as root or under sudo"
    exit 1
  fi
}

check_user
