#!/bin/sh

# shellcheck disable=SC2034
description="Test that pkg can build packages"

run_test() {
  $SSH_CMD 'ports >&2 && cd /usr/ports/pkg && pkg build >&2 && pkg add >&2'
}
