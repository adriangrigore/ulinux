#!/bin/sh

. ./functions.sh

SSH_CMD="ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2222 root@localhost"
export SSH_CMD

vm=
console=

cleanup() {
  if ps -p "$vm" > /dev/null; then
    kill $vm
  fi
  rm -rf "$console"
}

setup_vm() {
  progress "  Booting uLinux VM"
  console="$(mktemp -t 'ulinux-images-run-XXXXXX')"
  HEADLESS=1 ./test.sh > "$console" 2>&1 &
  vm=$!
}

wait_vm() {
  progress "  Waiting for VM"
  until $SSH_CMD '/bin/true' > /dev/null 2>&1; do
    sleep 0.1
  done
}

cleanup_vm() {
  progress "  Shutting down VM"
  $SSH_CMD '/sbin/poweroff'
  wait $vm
  ok

  progress "  Cleaning up"
  rm -rf "$console"
  ok
}

create_disk() {
  progress "  Creating disk"
  (
    rm -f "$DISK"
    qemu-img create -f qcow2 "$DISK" 1G
  ) >&2
}

install_ulinux() {
  progress "  Installing uLinux"
  (
    $SSH_CMD "/sbin/setup -r $DISKDEV"
  ) >&2
}

verify_install() {
  progress "  Verifying install"
  $SSH_CMD 'df -a -T | grep -q -E '''''/dev/root[[:space:]]+ext2''''''
}

build_generic_image() {
  progress "Building Generic Image"
  printf "\n"

  DISK="ulinux-generic.img"
  DISKIF="ide"
  DISKDEV="/dev/sda"
  export DISK DISKIF DISKDEV

  for substep in create_disk setup_vm wait_vm install_ulinux wait_vm verify_install cleanup_vm; do
    if ! run "$substep"; then
      fail "Build failed"
    fi
  done
}

build_digitalocean_image() {
  progress "Building DigitealOcean Image"
  printf "\n"

  DISK="ulinux-digitalocean.img"
  DISKIF="virtio"
  DISKDEV="/dev/vda"
  export DISK DISKIF DISKDEV

  for substep in create_disk setup_vm wait_vm install_ulinux wait_vm verify_install cleanup_vm; do
    if ! run "$substep"; then
      fail "Build failed"
    fi
  done
}

steps="build_generic_image build_digitalocean_image"

_main() {
  trap cleanup EXIT

  for step in $steps; do
    if ! run "$step"; then
      fail "Release failed"
    fi
  done

  echo "🎉 All Done!"
}

if [ -n "$0" ] && [ x"$0" != x"-bash" ]; then
  if ! _main "$@"; then
    fail "Release failed"
  fi
fi
