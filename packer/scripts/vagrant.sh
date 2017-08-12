#!/bin/bash

set -o errexit
set -o xtrace

VAGRANT_SSH_DIR="/home/vagrant/.ssh"
mkdir -pm 700 ${VAGRANT_SSH_DIR}
curl -L -o ${VAGRANT_SSH_DIR}/authorized_keys https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
chmod 0600 ${VAGRANT_SSH_DIR}/authorized_keys
chown -R vagrant:vagrant ${VAGRANT_SSH_DIR}

echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant
