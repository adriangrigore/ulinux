#!/bin/sh

# shellcheck disable=SC2034
description="Test that uLinux Boots up"

run_test() {
  $SSH_CMD '/bin/true'
}
