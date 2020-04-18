#!/bin/sh

# This file is included by download.sh & build.sh

set -e

KERNEL_VERSION=5.6.3
SYSLINUX_VERSION=6.03

CORE_PACKAGES="musl sinit make busybox dropbear extlinux"
CORE_PORTS="filesystem rc svc cloudinit net services ca-certificates tcc pkg box"

[ -n "$WITH_SSL" ] && CORE_PACKAGES="$CORE_PACKAGES libressl"
[ -n "$WITH_IPTABLES" ] && CORE_PACKAGES="$CORE_PACKAGES iptables"

export KERNEL_VERSION
export SYSLINUX_VERSION

export CORE_PACKAGES
export CORE_PORTS
