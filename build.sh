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

    # remove man/info pages
    rm -r "$rootfs"/usr/share/info
    rm -r "$rootfs"/usr/share/man
  )
}

build_sinit() {
  (
    cd sinit-$SINIT_VERSION
    make
    install -D -m 755 sinit "$rootfs"/sbin/init
  )
}

build_busybox() {
  (
    cd busybox-$BUSYBOX_VERSION
    make -j "$(nproc)" \
      distclean defconfig
    config y STATIC
    config n INCLUDE_SUSv2
    config "\"$rootfs\"" PREFIX
    config y FEATURE_EDITING_VI
    config y TUNE2FS
    config n BOOTCHARTD
    config n INIT
    config y HALT
    config y REBOOT
    config y POWEROFF
    config y FEATURE_CALL_TELINIT
    config "/sbin/telinit" TELINIT_PATH
    config n LINUXRC
    config y FEATURE_GPT_LABEL
    config n FEATURE_SKIP_ROOTFS
    config y FEATURE_WGET_HTTPS
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
    config n WHICH
    config n MAN
    config n RPM
    config n DEB
    config n DPKG
    config n DPKG_DEB
    yes "" | make oldconfig
    make -j "$(nproc)" \
      EXTRA_CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE" \
      busybox install
  )
}

build_dropbear() {
  (
    cd dropbear-$DROPBEAR_VERSION

    ./configure \
      --prefix=/usr \
      --mandir=/usr/man \
      --disable-zlib \
      --disable-wtmp

    make -j "$(nproc)" \
      EXTRA_CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE" \
      DESTDIR="$rootfs" \
      PROGRAMS="dropbear dbclient dropbearkey scp" \
      strip install

    ln -sf /usr/bin/dbclient "$rootfs"/usr/bin/ssh

    chmod u+s "$rootfs"/usr/sbin/dropbear
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
      LIBS="-l argp"
    make
    make DESTDIR="$rootfs" install
  )
}

build_iptables() {
  (
    cd iptables-$IPTABLES_VERSION
    ./configure \
      --prefix=/usr \
      --enable-libipq \
      --disable-nftables

    make -j "$(nproc)" \
      EXTRA_CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE"
    make DESTDIR="$rootfs" install
  )
}

write_metadata() {
  # Setup /etc/os-release with some nice contents
  latestTag="$(git describe --abbrev=0 --tags || echo "v0.0.0")"
  latestRev="$(git rev-parse --short HEAD)"
  fullVersion="$(echo "${latestTag}" | cut -c1-)"
  majorVersion="$(echo "${latestTag}" | cut -c1- | cut -d '.' -f 1,2)"
  cat > "$rootfs"/etc/os-release << EOF
NAME=µLinux
VERSION=$fullVersion
ID=ulinux
ID_LIKE=tcl
VERSION_ID=$fullVersion
PRETTY_NAME="µLinux (micro Linux) $fullVersion (TCL $majorVersion); $latestRev"
ANSI_COLOR="1;34"
HOME_URL="https://github.com/prologic/ulinux"
SUPPORT_URL="https://github.com/prologic/ulinux"
BUG_REPORT_URL="https://github.com/prologic/ulinux/issues"
EOF
}

build_ports() {
  # Bootstrap pkg
  install -D -m 755 ./ports/pkg/pkg /usr/local/bin/pkg

  # Copy ports tree into rootfs
  cp -r ports/* "$rootfs/usr/ports"

  for port in $CORE_PORTS; do
    (
      cd "ports/$port" || exit 1
      pkg build
      PKG_ROOT="$rootfs" pkg add .
    )
  done
}

build_rootfs() {
  (
    cd rootfs

    # Cleanup rootfs
    find . -type f -name '.empty' -size 0c -delete
    rm -rf "$rootfs"/usr/man
    rm -rf "$rootfs"/usr/share/man
    rm -rf "$rootfs"/usr/lib/pkgconfig

    if ! customize_rootfs "${rootfs}"; then
      error "customize_rootfs() returned non-zero"
    fi

    # Archive rootfs
    find . | cpio -R root:root -H newc -o | gzip -3 > ../rootfs.gz
  )
}

sync_rootfs() {
  (
    mkdir rootfs.old
    cd rootfs.old
    zcat < $build/rootfs.gz | cpio -idm
    rsync -aru . "$rootfs"
  )
}

build_kernel() {
  (
    cd linux-$KERNEL_VERSION
    make -j "$(nproc)" \
      mrproper tinyconfig kvmconfig

    # Disable debug symbols in kernel => smaller kernel binary.
    sed -i "s/^CONFIG_DEBUG_KERNEL.*/\\# CONFIG_DEBUG_KERNEL is not set/" .config

    # Enable the EFI stub
    sed -i "s/.*CONFIG_EFI_STUB.*/CONFIG_EFI_STUB=y/" .config

    # Basic Config
    config y 64BIT
    config y X86_64
    config y BLK_DEV_INITRD
    config y IKCONFIG
    config y IKCONFIG_PROC
    config y POSIX_TIMERS
    config y MODULES
    config y PRINTK
    config y TTY
    config y FUTEX
    config y EPOLL
    config y SMP
    config y SYSCTL_SYSCALL
    config y RETPOLINE
    config y RTC_CLASS
    config n DEBUG_KERNEL
    config n X86_VERBOSE_BOOTUP
    config ulinux DEFAULT_HOSTNAME

    # Security
    config y MULTIUSER
    config y FILE_LOCKING

    # Compression
    config y KERNEL_GZ
    config y RD_GZ
    config n RD_BZIP2
    config n RD_LZMA
    config n RD_XZ
    config n RD_LZO
    config n RD_LZ4

    # DHCP
    config y IP_PNP
    config y IP_PNP_DHCP

    # Executables
    config y BINFMT_ELF
    config y BINFMT_SCRIPT

    # File systems
    config y EXT4_FS
    config y EXT4_USE_FOR_EXT2
    config y DNOTIFY
    config y INOTIFY_USER
    config y FUSE_FS
    config y CUSE
    config y VIRTIO_FS
    config y ISO9660_FS
    config y VFAT_FS
    config y SYSFS
    config y PROC_FS
    config y DEVTMPFS
    config y TMPFS

    # Networking
    config y IPV6
    config y BRIDGE
    config y INET
    config y NETFILTER
    config y IP_NF_IPTABLES
    config y PACKET
    config y UNIX
    config y TLS
    config y IP_MULTICAST
    config y SYN_COOKIES
    config y INET_UDP_DIAG
    config y TUN

    # Driers
    config y E1000
    config y SCSI
    config y SCSI_VIRTIO
    config y BLK_DEV_SD
    config y CHR_DEV_ST
    config y BLK_DEV_SR
    config y IDE
    config y ATA
    config y ATA_PIIX
    config y USB
    config y USB_OHCI_HCD
    config y USB_UHCI_HCD
    config y VIRTIO
    config y CRYPTO_DEV_VIRTIO
    config y VIRTIO_PCI
    config y VIRTIO_MMIO
    config y VIRTIO_CONSOLE
    config y VIRTIO_BALLOON
    config y VIRTIO_INPUT
    config y VIRTIO_BLK
    config y VIRTIO_BLK_SCSI
    config y VIRTIO_NET
    config y HW_RANDOM_VIRTIO
    config y NET_TULIP

    # Docker / Container Basics (cgroups)
    config y NAMESPACES
    config y NET_NS
    config y PID_NS
    config y IPC_NS
    config y UTS_NS
    config y USER_NS
    config y CGROUPS
    config y CGROUP_PIDS
    config y CGROUP_CPUACCT
    config y CGROUP_DEVICE
    config y CGROUP_FREEZER
    config y CGROUP_SCHED
    config y CPUSETS
    config y CFS_BANDWIDTH
    config y MEMCG
    config y MEMCG_SWAP
    config y IOSCHED_CFQ
    config y CFQ_GROUP_IOSCHED
    config y KEYS
    config y VETH
    config y BRIDGE
    config y BRIDGE_NETFILTER
    config y IP_NF_FILTER
    config y IP_NF_TARGET_MASQUERADE
    config y NETFILTER_XT_MATCH_ADDRTYPE
    config y NETFILTER_XT_MATCH_CONNTRACK
    config y NETFILTER_XT_MATCH_IPVS
    config y NETFILTER_XT_NAT
    config y NF_NAT_NEEDED
    config y NF_NAT_IPV4
    config y IP_NF_NAT
    config y NF_NAT
    config y NF_NAT_IPV4
    config y NF_CONNTRACK
    config y NF_NAT_NEEDED
    config y POSIX_MQUEUE
    config y DEVPTS_MULTIPLE_INSTANCES

    # Docker / Networking (overlay)
    config y IP_VS
    config y IP_VS_RR
    config y IP_VS_NFCT
    config y IP_VS_PROTO_TCP
    config y IP_VS_PROTO_UDP
    config y VXLAN
    config y IPVLAN
    config y VLAN_8021Q
    config y BRIDGE_VLAN_FILTERING
    config y NF_CONNTRACK_MARK
    config y NETFILTER_XT_MARK
    config y NETFILTER_XT_CONNMARK
    config y XT_MATCH_CONNMARK
    config y NETFILTER_XT_MATCH_MARK
    config y XFRM
    config y XFRM_USER
    config y XFRM_ALGO
    config y INET_ESP
    config y INET_XFRM_MODE_TRANSPORT

    # Docker / Container Storage (cgroups, overlayfs, devmapper)
    config y BLK_DEV_DM
    config y DM_THIN_PROVISIONING
    config y OVERLAY_FS

    # Power Management
    config y ACPI
    config y PM

    # Trimming
    config y TRIM_UNUSED_KSYMS
    config y LTO_MENU
    config n SYSFS_SYSCALL
    config n ADVISE_SYSCALLS

    if ! customize_kernel; then
      error "customize_kernel() returned non-zero"
    fi

    make olddefconfig

    cp .config ../KConfig

    if [ -t 1 ]; then
      make menuconfig
    fi

    make -j "$(nproc)" \
      CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE" \
      bzImage

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

build_clouddrive() {
  xorrisofs -J -r -V cidata -o ./clouddrive.iso clouddrive/
}

build_all() {
  build_musl
  build_fasm
  build_make
  build_sinit
  build_busybox
  build_dropbear
  build_syslinux
  build_rngtools
  build_iptables
  build_kernel
  write_metadata
  build_ports
  build_rootfs
  build_iso
  build_clouddrive
}

repack() {
  sync_rootfs
  write_metadata
  build_rootfs
  build_iso
  build_clouddrive
}
