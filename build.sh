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
  progress "Building musl"
  (
    cd musl-$MUSL_VERSION

    ./configure \
      --prefix=/usr \
      --disable-static

    make -j "$(nproc)"
    make DESTDIR="$rootfs" install

    install -d "$rootfs"/usr/bin
    ln -s /usr/lib/libc.so "$rootfs/usr/bin/ldd"
  ) >&2
}

build_make() {
  progress "Building make"
  (
    cd make-$MAKE_VERSION

    ./configure --prefix=/usr --disable-nls

    make
    make DESTDIR="$rootfs" install

    # remove man/info pages
    rm -r "$rootfs"/usr/share/info
    rm -r "$rootfs"/usr/share/man
  ) >&2
}

build_sinit() {
  progress "Building sinit"
  (
    cd sinit-$SINIT_VERSION
    make
    install -D -m 755 sinit "$rootfs"/sbin/init
  ) >&2
}

build_busybox() {
  progress "Building busybox"
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
  ) >&2
}

build_dropbear() {
  progress "Building dropbear"
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
  ) >&2
}

build_syslinux() {
  progress "Building syslinux"
  (
    cd syslinux-$SYSLINUX_VERSION

    patch -p0 -i ../patches/syslinux-$SYSLINUX_VERSION/syslinux-Makefile.patch
    patch -p1 -i ../patches/syslinux-$SYSLINUX_VERSION/syslinux-sysmacros.patch
    patch -p1 -i ../patches/syslinux-$SYSLINUX_VERSION/extlinux-Makefile.patch

    make -j "$(nproc)" \
      installer
    make INSTALLROOT="$rootfs" install

    # Remove syslinux binary (we only need extlinux)
    rm -rf "${rootfs}"/usr/bin/syslinux

    # Remove c32 modules and bin(s) we don't need/want.
    rm -rf "$rootfs"/usr/share/syslinux/com32
    rm -rf "$rootfs"/usr/share/syslinux/diag
    rm -rf "$rootfs"/usr/share/syslinux/memdisk
    find "$rootfs"/usr/share/syslinux \
      -type f -name '*.c32' -delete
    find "$rootfs"/usr/share/syslinux \
      -type f -name '*.bin' ! -name 'mbr.bin' ! -name 'gptmbr.bin' -delete
    find "$rootfs"/usr/share/syslinux \
      -type f -name '*.0' -delete
    find "$rootfs"/usr/share/syslinux \
      -type d -exec rmdir {} --ignore-fail-on-non-empty +
  ) >&2
}

build_rngtools() {
  progress "Building rngtools"
  (
    cd rng-tools-$RNGTOOLS_VERSION
    ./configure \
      --prefix=/usr \
      --sbindir=/usr/sbin \
      LIBS="-l argp"
    make
    make DESTDIR="$rootfs" install
  ) >&2
}

build_iptables() {
  progress "Building iptables"
  (
    cd iptables-$IPTABLES_VERSION
    ./configure \
      --prefix=/usr \
      --enable-libipq \
      --disable-nftables

    make -j "$(nproc)" \
      EXTRA_CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE"
    make DESTDIR="$rootfs" install
  ) >&2
}

build_ports() {
  progress "Building ports"
  (
    # Bootstrap pkg
    install -D -m 755 ./ports/pkg/pkg /usr/local/bin/pkg

    # Copy ports tree into rootfs
    cp -r ports/* "$rootfs/usr/ports"

    for port in $CORE_PORTS; do
      (
        cd "ports/$port" || exit 1
        if ! pkg build; then
          fail "Failed to build port $port"
        fi
        if ! PKG_ROOT="$rootfs" pkg add .; then
          fail "Failed to install port $port"
        fi
      ) >&2
    done
  ) >&2
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

build_kernel() {
  progress "Building kernel"
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

    make headers_install INSTALL_HDR_PATH="$rootfs/usr"

    cp arch/x86/boot/bzImage ../kernel.gz
  ) >&2
}

build_iso() {
  progress "Building iso"
  (
    test -d "$isoimage" || mkdir "$isoimage"
    cp rootfs.gz "$isoimage"
    cp kernel.gz "$isoimage"
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
  progress "Building clouddrive"
  (
    xorrisofs -J -r -V cidata -o ./clouddrive.iso clouddrive/
  ) >&2
}

steps="build_musl build_make build_sinit build_busybox build_dropbear"
steps="$steps build_syslinux build_rngtools build_iptables build_kernel"
steps="$steps build_ports build_rootfs build_iso build_clouddrive"

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
