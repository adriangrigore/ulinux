#!/bin/sh

vm=
console=

setup() {
  console="$(mktemp -t 'ulinux-tests-run-XXXXXX')"

  progress "  Creating disk"
  rm -rf ulinux.img
  qemu-img create -f qcow2 ulinux.img 1G > /dev/null
  ok

  progress "  Booting uLinux VM"
  HEADLESS=1 ./test.sh > "$console" 2>&1 &
  vm=$!
  ok

  progress "  Waiting for VM"
  until $SSH_CMD '/bin/true' > /dev/null 2>&1; do
    sleep 0.1
  done
  ok
}

teardown() {
  progress "  Shutting down VM"
  $SSH_CMD '/sbin/poweroff'
  wait $vm
  ok

  progress "  Cleaning up"
  rm -rf "$console"
  ok
}
