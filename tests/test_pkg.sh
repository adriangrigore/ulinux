#!/bin/sh

# shellcheck disable=SC2034
description="Test that pkg is installed"

run_test() {
  result="$($SSH_CMD 'pkg list | grep -o pkg')"
  [ -n "$result" ] && [ "$result" = "pkg" ]
}
