#!/bin/sh

vm=
console=

setup() {
  console="$(mktemp -t 'ulinux-tests-run-XXXXXX')"

  progress "Booting test uLinux VM"
  HEADLESS=1 ./test.sh > "$console" 2>&1 &
  vm=$!
  ok

  progress "Waiting for VM to become available"
  until $SSH_CMD '/bin/true' > /dev/null 2>&1; do
    sleep 0.1
  done
  ok
}

teardown() {
  progress "Shutting down uLinux Test VM"
  $SSH_CMD '/sbin/poweroff'
  wait $vm
  ok

  progress "Cleaning up"
  rm -rf "$console"
  ok
}
