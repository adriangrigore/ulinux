#!/bin/sh

# shellcheck disable=SC2034
description="Test that we have 10 packages"

run_test() {
  result="$($SSH_CMD 'pkg list | wc -l')"
  [ -n "$result" ] && [ "$result" -eq 10 ]
}
