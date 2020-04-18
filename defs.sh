#!/bin/sh

# This file is included by download.sh & build.sh

set -e

KERNEL_VERSION=5.6.3
BUSYBOX_VERSION=20200412
DROPBEAR_VERSION=2019.78
SYSLINUX_VERSION=6.03
RNGTOOLS_VERSION=5
IPTABLES_VERSION=1.8.2

CORE_PACKAGES="musl sinit make"
CORE_PORTS="filesystem rc svc cloudinit net services ca-certificates tcc pkg box"

[ -n "$WITH_SSL" ] && CORE_PACKAGES="$CORE_PACKAGES libressl"

export KERNEL_VERSION
export BUSYBOX_VERSION
export DROPBEAR_VERSION
export SYSLINUX_VERSION
export RNGTOOLS_VERSION
export IPTABLES_VERSION

export CORE_PACKAGES
export CORE_PORTS
