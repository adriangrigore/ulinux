#!/bin/sh

if [ "$(uname -s)" = "Darwin" ]; then
  accel="hvf"
else
  accel="kvm"
fi

QEMU_OPTS=

[ -n "$HEADLESS" ] && QEMU_OPTS="$QEMU_OPTS -nographic"
[ -n "$CLOUDDRIVE" ] && QEMU_OPTS="$QEMU_OPTS -drive file=clouddrive.iso,index=1,media=cdrom"

[ -z "$DISK" ] && DISK="ulinux.img"
[ -z "$DISKIF" ] && DISKIF="ide"
[ -n "$DISK" ] && QEMU_OPTS="$QEMU_OPTS -drive file=$DISK,index=1,media=disk,if=$DISKIF,cache=writethrough"

QEMU_OPTS="$QEMU_OPTS
-accel $accel,thread=multi
-m 1024
-cpu qemu64
-rtc base=utc,clock=host
-boot order=cd,menu=off
-drive file=ulinux.iso,index=0,media=cdrom
-device virtio-rng-pci
-net nic -net user,hostfwd=tcp::2222-:22"

exec qemu-system-x86_64 $QEMU_OPTS
