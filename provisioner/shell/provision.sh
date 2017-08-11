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

function start_service {
  local SERVICE=$1

  if ! systemctl is-enabled ${SERVICE} &>/dev/null ; then
    >2 echo "Service ${SERVICE} not enabled; enabling..."
    systemctl enable ${SERVICE}
  fi

  if ! systemctl is-active ${SERVICE} &>/dev/null ; then
    >2 echo "Service ${SERVICE} not active; starting..."
    systemctl start ${SERVICE}
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

function set_php_timezone {
  local TIMEZONE=$1

  CURRENT_TZ=$(php -i | grep "^date.timezone")

  if [[ ! "${CURRENT_TZ}" =~ "${TIMEZONE}" ]]; then
    >2 echo "PHP TZ is not set to ${TIMEZONE}; setting..."
    echo "date.timezone=${TIMEZONE}" > /etc/php.d/zz-timezone.ini
  fi
}

function set_timezone {
  local TIMEZONE=$1

  set_system_timezone "${TIMEZONE}"
  set_php_timezone "${TIMEZONE}"
}

function create_phpinfo {
  local FILE="/var/www/html/phpinfo.php"

  if [ ! -e "${FILE}" ] ; then
    >2 echo "phpinfo() not found; creating..."

    cat > "${FILE}" <<EOF
    <?php phpinfo(); ?>
EOF
fi
}

function open_firewall_port {
  local SERVICE=$1

  if ! firewall-cmd --zone=public --query-service=${SERVICE} ; then
    >2 echo "Firewall port for ${SERVICE} not open; adding rule..."
    firewall-cmd --permanent --zone=public --add-service=http
    firewall-cmd --reload
  fi
}


check_user
install_package 'httpd'
install_package 'php'
set_timezone 'Australia/Adelaide'
start_service 'httpd'
create_phpinfo
open_firewall_port 'http'

echo "Completed"
