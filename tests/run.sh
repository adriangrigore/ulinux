#!/bin/sh
# shellcheck disable=SC1090

. "$(dirname "$0")/functions.sh"
. "$(dirname "$0")/fixtures.sh"

_main() {
  setup || fail "Failed to setup fixtures"
  trap teardown EXIT

  description=
  for tf in "$(dirname "$0")"/test_*.sh; do
    # shellcheck disable=SC1090
    . ./"$tf" || fail "Failed to source test file"
    progress "  $description"
    run run_test
  done
}

if [ -n "$0" ] && [ x"$0" != x"-bash" ]; then
  progress "Running test suite"
  printf "\n"
  run _main "$@"
fi
