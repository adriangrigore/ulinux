#!/bin/sh

set -e

# shellcheck source=functions.sh
. functions.sh

# shellcheck source=defs.sh
. defs.sh

download_syslinux() {
  progress "Downloading syslinux"
  wget -q -O syslinux.tar.xz \
    http://kernel.org/pub/linux/utils/boot/syslinux/syslinux-$SYSLINUX_VERSION.tar.xz
  tar -xf syslinux.tar.xz
}

download_kernel() {
  progress "Downloading kernel"
  wget -q -O kernel.tar.xz \
    https://cdn.kernel.org/pub/linux/kernel/v"$(echo "$KERNEL_VERSION" | cut -f 1 -d '.')".x/linux-${KERNEL_VERSION}.tar.xz
  tar -xf kernel.tar.xz
}

steps="$steps download_syslinux"
steps="$steps download_kernel"

download_all() {
  for step in $steps; do
    run "$step" || exit 1
  done
}
