#!/bin/sh

# shellcheck disable=SC2034
description="Test that box sandboxing works"

run_test() {
  result="$($SSH_CMD 'box id -u')"
  [ -n "$result" ] && [ "$result" -ne 0 ]
}
