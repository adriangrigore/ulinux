#!/bin/sh

set -e

. ./functions.sh
. ./defs.sh

build=/build
rootfs=$build/rootfs
isoimage=$build/isoimage

if [ -f customize.sh ]; then
  # shellcheck source=customize.sh
  . customize.sh
else
  printf >&2 "WARNING: Cannot source customize.sh\n"
fi

pkg_build_add() {
  (
    cd "$1" || exit 1
    pkg build
    PKG_ROOT="$rootfs" pkg add .
  ) >&2
}

build_packages() {
  progress "Building packages"
  printf "\n"

  for package in $CORE_PACKAGES; do
    progress "  Building package $package"
    run pkg_build_add "packages/$package"
  done
}

build_ports() {
  progress "Building ports"
  printf "\n"

  for port in $CORE_PORTS; do
    progress "  Building port $port"
    run pkg_build_add "ports/$port"
  done
}

build_rootfs() {
  progress "Building rootfs"
  (
    cd rootfs

    # Cleanup rootfs
    rm -rf "$rootfs"/usr/man
    rm -rf "$rootfs"/usr/share/man
    rm -rf "$rootfs"/usr/lib/pkgconfig

    if ! customize_rootfs "${rootfs}"; then
      error "customize_rootfs() returned non-zero"
    fi

    # Archive rootfs
    find . | cpio -R root:root -H newc -o | gzip -3 > ../rootfs.gz
  ) >&2
}

build_iso() {
  progress "Building iso"
  (
    test -d "$isoimage" || mkdir "$isoimage"

    # Extract Kernel from the kernel package
    tar xvf ./packages/kernel/kernel*#*.tar.gz ./boot/vmlinuz
    mv ./boot/vmlinuz "$isoimage"/kernel.gz

    cp rootfs.gz "$isoimage"
    cp syslinux-$SYSLINUX_VERSION/bios/core/isolinux.bin "$isoimage"
    cp syslinux-$SYSLINUX_VERSION/bios/com32/elflink/ldlinux/ldlinux.c32 "$isoimage"
    echo 'default kernel.gz initrd=rootfs.gz append quiet rdinit=/sbin/init' > "$isoimage/isolinux.cfg"

    cd "$isoimage"
    xorriso \
      -as mkisofs \
      -o ../ulinux.iso \
      -b isolinux.bin \
      -c boot.cat \
      -no-emul-boot \
      -boot-load-size 4 \
      -boot-info-table \
      ./
  ) >&2
}

build_clouddrive() {
  xorrisofs -J -r -V cidata -o ./clouddrive.iso clouddrive/
}

steps="build_packages build_ports build_rootfs build_iso"

build_all() {
  for step in $steps; do
    if ! run "$step"; then
      if [ -t 1 ]; then
        debug
      else
        fail "Build failed"
      fi
    fi
  done

  echo "🎉 All Done!"
}
