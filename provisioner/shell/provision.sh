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

function set_system_timezone {
  local TIMEZONE=$1

  EXPECTED_TZFILE="/usr/share/zoneinfo/${TIMEZONE}"

  if [ ! -e ${EXPECTED_TZFILE} ] ; then
    >2 echo "No timezone file for ${TIMEZONE} found; exiting..."
    exit 1
  fi

  ACTIVE_TZFILE=$(readlink -f /etc/localtime)

  if [ "${ACTIVE_TZFILE}" != "${EXPECTED_TZFILE}" ] ; then
    >2 echo "System TZ is not set to ${TIMEZONE}; setting..."
    timedatectl set-timezone ${TIMEZONE}
  fi
}

function set_timezone {
  local TIMEZONE=$1

  set_system_timezone "${TIMEZONE}"
}

check_user
install_package httpd
install_package php
set_timezone 'Australia/Adelaide'
