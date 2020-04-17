#!/bin/sh

# shellcheck disable=SC2034
description="Test that pkg can build packages"

run_test() {
  $SSH_CMD 'ports && cd /usr/ports/pkg && pkg build && pkg add'
}
