#!/bin/sh

vm=
console=

create_disk() {
  progress "  Creating disk"
  (
    rm -rf ulinux.img
    qemu-img create -f qcow2 ulinux.img 1G > /dev/null
  ) >&2
}

create_vm() {
  progress "  Booting uLinux VM"
  HEADLESS=1 ./test.sh > "$console" 2>&1 &
  vm=$!
  sleep 3
}

wait_vm() {
  progress "  Waiting for VM"
  (
    if ! timeout 15s wait_for_ssh.sh; then
      cat "$console"
      fail "VM did not come up in time!"
    fi
  ) >&2
}

setup() {
  console="$(mktemp -t 'ulinux-tests-run-XXXXXX')"

  for setup_step in create_disk create_vm wait_vm; do
    if ! run "$setup_step"; then
      fail "Setup failed"
    fi
  done
}

cleanup() {
  if ps -p "$vm" > /dev/null; then
    kill "$vm"
  fi
  rm -rf "$console"
}

shutdown_vm() {
  progress "  Shutting down VM"
  $SSH_CMD '/sbin/poweroff'
  if ps -p "$vm" > /dev/null; then
    kill "$vm"
  fi
}

cleanup_vm() {
  progress "  Cleaning up VM"
  rm -rf "$console"
}

teardown() {
  for teardown_step in shutdown_vm cleanup_vm; do
    if ! run "$teardown_step"; then
      fail "Teardown failed"
    fi
  done
}
