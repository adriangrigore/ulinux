#!/bin/sh

# shellcheck disable=SC2034
description="Test that setup works"

install_ulinux() {
  progress "    Installing uLinux"
  (
    $SSH_CMD '/sbin/setup -r /dev/sda'
  ) >&2
}

verify_install() {
  progress "    Verifying install"
  (
    $SSH_CMD 'df -a -T | grep -q -E '''''/dev/root[[:space:]]+ext2''''''
  ) >&2
}

run_test() {
  printf "\n"
  for substep in install_ulinux wait_vm2 verify_install; do
    if ! run "$substep"; then
      fail "Test failed"
    fi
  done
}
