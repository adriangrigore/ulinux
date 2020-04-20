#!/bin/sh

# shellcheck disable=SC2034
description="Test that setup works"

wait_vm() {
  progress "  Waiting for VM"
  until $SSH_CMD '/bin/true' > /dev/null 2>&1; do
    sleep 0.1
  done
}

install_ulinux() {
  progress "  Installing uLinux"
  (
    $SSH_CMD '/sbin/setup -r /dev/sda'
  ) >&2
}

verify_install() {
  progress "  Verifying install"
  $SSH_CMD 'df -a -T | grep -q -E '''''/dev/root[[:space:]]+ext2''''''
}

run_test() {
  printf "\n"
  for substep in install_ulinux wait_vm verify_install; do
    if ! run "$substep"; then
      fail "Test failed"
    fi
  done
}