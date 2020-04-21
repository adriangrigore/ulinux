#!/bin/sh

# This file is included by download.sh & build.sh

set -e

# uLinux version/tag (passed in from the environment or defaulted to git)
TAG="${TAG:-$(git describe --abbrev=0 --tags || echo "v0.0.0")}"
REV="${REV:-$(git rev-parse --short HEAD || echo "0000000")}"

SYSLINUX_VERSION=6.03

CORE_PKGS="kernel musl sinit make busybox dropbear extlinux"
CORE_PORTS="filesystem rc svc cloudinit net services ca-certificates tcc pkg setup box"

[ -n "$WITH_SSL" ] && CORE_PKGS="$CORE_PKGS libressl"
[ -n "$WITH_IPTABLES" ] && CORE_PKGS="$CORE_PKGS iptables"

export TAG
export REV

export SYSLINUX_VERSION

export CORE_PKGS
export CORE_PORTS
