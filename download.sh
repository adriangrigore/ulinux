#!/bin/sh

set -e

# shellcheck source=functions.sh
. functions.sh

# shellcheck source=defs.sh
. defs.sh

download_syslinux() {
  wget -q -O syslinux.tar.xz \
    http://kernel.org/pub/linux/utils/boot/syslinux/syslinux-$SYSLINUX_VERSION.tar.xz
  tar -xf syslinux.tar.xz
}

download_kernel() {
  wget -q -O kernel.tar.xz \
    https://cdn.kernel.org/pub/linux/kernel/v"$(echo "$KERNEL_VERSION" | cut -f 1 -d '.')".x/linux-${KERNEL_VERSION}.tar.xz
  tar -xf kernel.tar.xz
}

download_musl() {
  wget -q -O musl.tar.gz \
    http://www.musl-libc.org/releases/musl-$MUSL_VERSION.tar.gz
  tar -xf musl.tar.gz
}

download_tcc() {
  wget -q -O tcc.tar.gz \
    https://repo.or.cz/tinycc.git/snapshot/$TCC_VERSION.tar.gz
  tar -xf tcc.tar.gz
}

download_fasm() {
  wget -q -O fasm.tgz \
    https://flatassembler.net/fasm-$FASM_VERSION.tgz
  tar -xf fasm.tgz
}

download_make() {
  wget -q -O make.tar.lz \
    http://ftpmirror.gnu.org/gnu/make/make-$MAKE_VERSION.tar.lz
  tar -xf make.tar.lz
}

download_busybox() {
  wget -q -O busybox.tar.bz2 \
    http://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
  tar -xf busybox.tar.bz2
}

download_dropbear() {
  wget -q -O dropbear.tar.bz2 \
    https://matt.ucc.asn.au/dropbear/dropbear-$DROPBEAR_VERSION.tar.bz2
  tar -xf dropbear.tar.bz2
}

download_rngtools() {
  wget -q -O rngtools.tar.gz \
    https://downloads.sourceforge.net/sourceforge/gkernel/rng-tools-$RNGTOOLS_VERSION.tar.gz
  tar -xf rngtools.tar.gz
}

download_iptables() {
  wget -q -O iptables.tar.bz2 \
    https://netfilter.org/projects/iptables/files/iptables-$IPTABLES_VERSION.tar.bz2
  tar -xf iptables.tar.bz2
}

download_all() {
  download_musl
  download_tcc
  download_fasm
  download_make
  download_busybox
  download_dropbear
  download_syslinux
  download_rngtools
  download_iptables
  download_kernel
}
