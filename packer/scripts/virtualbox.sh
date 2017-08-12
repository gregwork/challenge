#!/bin/bash

set -o errexit

export KERN_DIR=/usr/src/kernels/$(uname -r)

mount /dev/sr1 /mnt
/mnt/VBoxLinuxAdditions.run --nox11
umount /mnt
