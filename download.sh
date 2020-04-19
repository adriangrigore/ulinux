#!/bin/sh

set -e

. ./functions.sh
. ./defs.sh

download_syslinux() {
  progress "Downloading syslinux"
  wget -q -O syslinux.tar.xz \
    http://kernel.org/pub/linux/utils/boot/syslinux/syslinux-$SYSLINUX_VERSION.tar.xz
  tar -xf syslinux.tar.xz
}

steps="download_syslinux"

download_all() {
  for step in $steps; do
    run "$step" || exit 1
  done
}
