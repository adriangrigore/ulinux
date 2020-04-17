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

download_musl() {
  progress "Downloading musl"
  wget -q -O musl.tar.gz \
    http://www.musl-libc.org/releases/musl-$MUSL_VERSION.tar.gz
  tar -xf musl.tar.gz
}

download_make() {
  progress "Downloading make"
  wget -q -O make.tar.lz \
    http://ftpmirror.gnu.org/gnu/make/make-$MAKE_VERSION.tar.lz
  tar -xf make.tar.lz
}

download_sinit() {
  progress "Downloading sinit"
  if [ "$SINIT_VERSION" = "master" ]; then
    git clone git://git.suckless.org/sinit sinit-$SINIT_VERSION
  else
    wget -q -O sinit.tar.gz \
      https://dl.suckless.org/sinit/sinit-$SINIT_VERSION.tar.gz
    tar -xf sinit.tar.gz
  fi
}

download_busybox() {
  progress "Downloading busybox"
  if [ "$BUSYBOX_VERSION" = "snapshot" ]; then
    wget -q -O busybox.tar.bz2 \
      https://busybox.net/downloads/snapshots/busybox-snapshot.tar.bz2
    tar -xf busybox.tar.bz2
    mv busybox busybox-$BUSYBOX_VERSION
  elif fnmatch "2020[0-9]*" "$BUSYBOX_VERSION"; then
    wget -q -O busybox.tar.bz2 \
      https://busybox.net/downloads/snapshots/busybox-$BUSYBOX_VERSION.tar.bz2
    tar -xf busybox.tar.bz2
    mv busybox busybox-$BUSYBOX_VERSION
  else
    wget -q -O busybox.tar.bz2 \
      http://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
    tar -xf busybox.tar.bz2
  fi

}

download_dropbear() {
  progress "Downloading dropbear"
  wget -q -O dropbear.tar.bz2 \
    https://matt.ucc.asn.au/dropbear/dropbear-$DROPBEAR_VERSION.tar.bz2
  tar -xf dropbear.tar.bz2
}

download_rngtools() {
  progress "Downloading rngtools"
  wget -q -O rngtools.tar.gz \
    https://downloads.sourceforge.net/sourceforge/gkernel/rng-tools-$RNGTOOLS_VERSION.tar.gz
  tar -xf rngtools.tar.gz
}

download_iptables() {
  progress "Downloading iptables"
  wget -q -O iptables.tar.bz2 \
    https://netfilter.org/projects/iptables/files/iptables-$IPTABLES_VERSION.tar.bz2
  tar -xf iptables.tar.bz2
}

steps="download_musl download_make download_sinit download_busybox"
steps="$steps download_dropbear download_syslinux download_rngtools"
steps="$steps download_iptables download_kernel"

download_all() {
  for step in $steps; do
    run "$step" || exit 1
  done
}
