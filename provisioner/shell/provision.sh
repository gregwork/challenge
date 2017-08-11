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

function install_package {
  local PACKAGE=$1

  if ! rpm -q ${PACKAGE} &>/dev/null ; then
    >2 echo "Package ${PACKAGE} not installed; installing..."
    yum --assumeyes install ${PACKAGE}
  fi
}

check_user
install_package httpd
install_package php
