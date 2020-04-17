#!/bin/sh

# shellcheck disable=SC2034
description="Test that box sandboxing works"

run_test() {
  $SSH_CMD 'box touch /root/foo'
  result="$($SSH_CMD 'ls -1 /root/foo*')"
  [ -z "$result" ]
}
