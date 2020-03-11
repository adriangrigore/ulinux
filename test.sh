#!/bin/sh

exec qemu-system-x86_64 \
  -m 1024 \
  -cpu qemu64 \
  -cdrom ulinux.iso \
  -hda ulinux.img \
  -boot order=cd,menu=off \
  -device virtio-rng-pci \
  -net nic -net user,hostfwd=tcp::2222-:22
