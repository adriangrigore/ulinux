#!/bin/sh

exec qemu-system-x86_64 \
  -m 1024 \
  -cpu qemu64 \
  -boot order=cd,menu=off \
  -drive file=ulinux.iso,index=0,media=cdrom \
  -drive file=clouddrive.iso,index=1,media=cdrom \
  -drive file=ulinux.img,media=disk,cache=writethrough \
  -device virtio-rng-pci \
  -net nic -net user,hostfwd=tcp::2222-:22
