#!/bin/sh

QEMU_OPTS=

if [ "$(uname -s)" = "Darwin" ]; then
  QEMU_OPTS="$QEMU_OPTS -accel hvf,thread=multi"
else
  if grep flags /proc/cpuinfo | head -n 1 | grep -q -E '(vmx|svm)'; then
    QEMU_OPTS="$QEMU_OPTS -accel kvm,thread=multi"
  fi
fi

[ -n "$HEADLESS" ] && QEMU_OPTS="$QEMU_OPTS -nographic"
[ -n "$CLOUDDRIVE" ] && QEMU_OPTS="$QEMU_OPTS -drive file=clouddrive.iso,index=1,media=cdrom"

[ -z "$DISK" ] && DISK="ulinux.img"
[ -z "$DISKIF" ] && DISKIF="ide"
[ -n "$DISK" ] && QEMU_OPTS="$QEMU_OPTS -drive file=$DISK,index=1,media=disk,if=$DISKIF,cache=writethrough"

QEMU_OPTS="$QEMU_OPTS
-m 1024
-cpu qemu64
-rtc base=utc,clock=host
-boot order=cd,menu=off
-drive file=ulinux.iso,index=0,media=cdrom
-device virtio-rng-pci
-net nic -net user,hostfwd=tcp::2222-:22"

exec qemu-system-x86_64 $QEMU_OPTS
