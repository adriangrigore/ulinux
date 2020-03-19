#!/bin/sh

set -e

# shellcheck source=functions.sh
. functions.sh

# shellcheck source=defs.sh
. defs.sh

build=/build
rootfs=$build/rootfs
isoimage=$build/isoimage

if [ -f customize.sh ]; then
  # shellcheck source=customize.sh
  . customize.sh
else
  printf >&2 "WARNING: Cannot source customize.sh\n"
fi

build_musl() {
  (
    cd musl-$MUSL_VERSION

    ./configure \
      --prefix=/usr

    make
    make DESTDIR="$rootfs" install

    ln -s /usr/lib/libc.so "$rootfs/usr/bin/ldd"
  )
}

build_tcc() {
  (
    gitver="$(echo "$TCC_VERSION" | cut -c1-7)"
    cd tinycc-"${gitver}"

    patch -p1 -i ../patches/tinycc-"${gitver}"/Makefile.patch
    patch -p1 -i ../patches/tinycc-"${gitver}"/bt-log-stdarg.patch

    ./configure \
      --prefix=/usr \
      --config-musl

    make
    make DESTDIR="$rootfs" install
  )
}

build_fasm() {
  (
    cd fasm

    FASM=fasm.x64

    mkdir -p build

    # compile fasm with itself
    ./${FASM} ./source/Linux/fasm.asm ./build/fasm
    chmod +x ./build/fasm

    ./${FASM} ./source/Linux/x64/fasm.asm ./build/fasm.x64
    chmod +x ./build/fasm.x64

    install -Dm 755 ./build/fasm -t "$rootfs/usr/bin"
    ln -s "fasm" "$rootfs/usr/bin/fasm32"
    chmod 755 "$rootfs/usr/bin/fasm32"

    install -Dm 755 ./build/fasm.x64 -t "$rootfs/usr/bin"
    ln -s "fasm.x64" "$rootfs/usr/bin/fasm64"
    chmod 755 "$rootfs/usr/bin/fasm64"
  )
}

build_make() {
  (
    cd make-$MAKE_VERSION

    ./configure --prefix=/usr --disable-nls

    make
    make DESTDIR="$rootfs" install
    rm -r "$rootfs"/usr/share/info
    rm -r "$rootfs"/usr/share/man
  )
}

build_v() {
  (
    cd v-$V_VERSION

    make

    # build tools
    for tool in cmd/tools/vrepl.v cmd/tools/vtest.v cmd/tools/vfmt.v cmd/tools/vcreate.v cmd/tools/vup.v; do
      echo "build $tool"
      ./v build $tool
    done

    # manually install binaries
    install -D -m 0755 v "$rootfs"/usr/lib/v/v

    for instdir in cmd vlib; do
      cp -r $instdir "$rootfs"/usr/lib/v
    done

    # install wrapper
    mkdir -p "$rootfs"/usr/bin
    cat > "$rootfs"/usr/bin/v << EOF
#!/bin/sh

export CC=tcc
export VFLAGS='-cc tcc'

exec /usr/lib/v/v "\$@"
EOF
    chmod 0755 "$rootfs"/usr/bin/v
  )
}

build_busybox() {
  (
    cd busybox-$BUSYBOX_VERSION
    make distclean defconfig -j "$NUM_JOBS"
    config y STATIC
    config n INCLUDE_SUSv2
    config y INSTALL_NO_USR
    config "\"$rootfs\"" PREFIX
    config y FEATURE_EDITING_VI
    config y TUNE2FS
    config n BOOTCHARTD
    config n INIT
    config n LINUXRC
    config y FEATURE_GPT_LABEL
    config n LPD
    config n LPR
    config n LPQ
    config n RUNSV
    config n RUNSVDIR
    config n SV
    config n SVC
    config n SVLOGD
    config n HUSH
    config n CHAT
    config n CONSPY
    config n RUNLEVEL
    config n PIPE_PROGRESS
    config n RUN_PARTS
    config n START_STOP_DAEMON
    config n MAN
    yes "" | make oldconfig
    make \
      EXTRA_CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE" \
      busybox install -j "$NUM_JOBS"
  )
}

build_dropbear() {
  (
    cd dropbear-$DROPBEAR_VERSION
    ./configure \
      --prefix=/usr \
      --mandir=/usr/man \
      --enable-static \
      --disable-zlib \
      --disable-wtmp \
      --disable-syslog

    make \
      EXTRA_CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE" \
      DESTDIR="$rootfs" \
      PROGRAMS="dropbear dbclient dropbearkey scp" \
      strip install -j "$NUM_JOBS"
    ln -sf /usr/bin/dbclient "$rootfs"/usr/bin/ssh
  )
}

build_syslinux() {
  (
    cd syslinux-$SYSLINUX_VERSION

    patch -p0 -i ../patches/syslinux-$SYSLINUX_VERSION/syslinux-Makefile.patch
    patch -p1 -i ../patches/syslinux-$SYSLINUX_VERSION/syslinux-sysmacros.patch
    patch -p1 -i ../patches/syslinux-$SYSLINUX_VERSION/extlinux-Makefile.patch

    make installer
    make INSTALLROOT="$rootfs" install
  )
}

build_rngtools() {
  (
    cd rng-tools-$RNGTOOLS_VERSION
    ./configure \
      --prefix=/usr \
      --sbindir=/usr/sbin \
      CFLAGS="-static" LIBS="-l argp"
    make
    make DESTDIR="$rootfs" install
  )
}

write_metadata() {
  # Setup /etc/os-release with some nice contents
  latestTag="$(git describe --abbrev=0 --tags || echo "v0.0.0")"
  latestRev="$(git rev-parse --short HEAD)"
  fullVersion="$(echo "${latestTag}" | cut -c2-)"
  majorVersion="$(echo "${latestTag}" | cut -c2- | cut -d '.' -f 1,2)"
  cat > "$rootfs"/etc/os-release << EOF
NAME=micro Linux
VERSION=$fullVersion
ID=ulinux
ID_LIKE=tcl
VERSION_ID=$fullVersion
PRETTY_NAME="micro Linux $fullVersion (TCL $majorVersion); $latestRev"
ANSI_COLOR="1;34"
HOME_URL="https://github.com/prologic/ulinux"
SUPPORT_URL="https://github.com/prologic/ulinux"
BUG_REPORT_URL="https://github.com/prologic/ulinux/issues"
EOF
}

build_rootfs() {
  (
    cd rootfs

    # Cleanup rootfs
    find . -type f -name '.empty' -size 0c -delete
    rm -rf "$rootfs"/usr/man
    rm -rf "$rootfs"/usr/share/man

    # install static-get
    wget -q -O - https://raw.githubusercontent.com/minos-org/minos-static/master/static-get > "${rootfs}"/sbin/static-get
    chmod 755 "${rootfs}"/sbin/static-get

    if ! customize_rootfs "${rootfs}"; then
      error "customize_rootfs() returned non-zero"
    fi

    # Archive rootfs
    find . | cpio -R root:root -H newc -o | gzip -9 > ../rootfs.gz
  )
}

sync_rootfs() {
  (
    mkdir rootfs.old
    cd rootfs.old
    zcat $build/rootfs.gz | cpio -idm
    rsync -aru . "$rootfs"
  )
}

build_kernel() {
  (
    cd linux-$KERNEL_VERSION
    make mrproper defconfig kvmconfig -j "$NUM_JOBS"

    # Disable debug symbols in kernel => smaller kernel binary.
    sed -i "s/^CONFIG_DEBUG_KERNEL.*/\\# CONFIG_DEBUG_KERNEL is not set/" .config

    # Enable the EFI stub
    sed -i "s/.*CONFIG_EFI_STUB.*/CONFIG_EFI_STUB=y/" .config

    # Basic Config
    config y BLK_DEV_INITRD
    config y IKCONFIG
    config y IKCONFIG_PROC
    config y DEVTMPFS
    config n DEBUG_KERNEL
    config n X86_VERBOSE_BOOTUP
    config ulinux DEFAULT_HOSTNAME

    config y IP_PNP
    config y IP_PNP_DHCP

    # RNG
    config y HW_RANDOM_VIRTIO

    # Network Driers
    config y VIRTIO
    config y VIRTIO_PCI
    config y VIRTIO_MMIO
    config y VIRTIO_CONSOLE
    config y VIRTIO_IDE
    config y VIRTIO_SCSI
    config y VIRTIO_BLK
    config y VIRTIO_NET

    if ! customize_kernel; then
      error "customize_kernel() returned non-zero"
    fi

    yes "" | make oldconfig
    make \
      CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE" \
      bzImage -j "$NUM_JOBS"
    cp arch/x86/boot/bzImage ../kernel.gz
  )
}

build_iso() {
  test -d "$isoimage" || mkdir "$isoimage"
  cp rootfs.gz "$isoimage"
  cp kernel.gz "$isoimage"
  cp syslinux-$SYSLINUX_VERSION/bios/core/isolinux.bin "$isoimage"
  cp syslinux-$SYSLINUX_VERSION/bios/com32/elflink/ldlinux/ldlinux.c32 "$isoimage"
  echo 'default kernel.gz initrd=rootfs.gz append quiet rdinit=/sbin/init' > "$isoimage/isolinux.cfg"

  (
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
  )
}

build_all() {
  build_musl
  build_tcc
  build_fasm
  build_make
  build_v
  build_busybox
  build_dropbear
  build_syslinux
  build_rngtools
  build_kernel
  write_metadata
  build_rootfs
  build_iso
}

repack() {
  sync_rootfs
  write_metadata
  build_rootfs
  build_iso
}
