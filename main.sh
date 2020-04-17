#!/bin/sh

set -e

# shellcheck source=download.sh
. download.sh

# shellcheck source=build.sh
. build.sh

fail() {
  printf "FAIL: %s\n" "$1"
  if [ -t 1 ]; then
    printf "Dropping into a shell ..."
    exec /bin/sh
  fi
}

_main() {
  case "${1}" in
    build)
      build_all
      ;;
    download)
      download_all
      ;;
    clouddrive)
      build_clouddrive
      ;;
    *)
      download_all
      build_all
      ;;
  esac
}

_main "${@}" || fail "Build failed ..."
