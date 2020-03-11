#!/bin/sh

# This file is included by build.sh to customize the build

customize_kernel() {
  return 0
}

customize_rootfs() {
  rootfs="${1}"
  (
    cd "${rootfs}" || exit 1
  )
  return 0
}
