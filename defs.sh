#!/bin/sh

# This file is included by download.sh & build.sh

set -e

# uLinux version/tag (passed in from the environment or defaulted to git)
TAG="${TAG:-$(git describe --abbrev=0 --tags || echo "v0.0.0")}"
REV="${REV:-$(git rev-parse --short HEAD || echo "0000000")}"

KERNEL_VERSION=5.6.3
SYSLINUX_VERSION=6.03

CORE_PACKAGES="musl sinit make busybox dropbear extlinux"
CORE_PORTS="filesystem rc svc cloudinit net services ca-certificates tcc pkg box"

[ -n "$WITH_SSL" ] && CORE_PACKAGES="$CORE_PACKAGES libressl"
[ -n "$WITH_IPTABLES" ] && CORE_PACKAGES="$CORE_PACKAGES iptables"

export TAG
export REV

export KERNEL_VERSION
export SYSLINUX_VERSION

export CORE_PACKAGES
export CORE_PORTS
