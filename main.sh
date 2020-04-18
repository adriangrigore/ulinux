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
    sh*)
      exec /bin/sh
      ;;
    *)
      download_all
      build_all
      ;;
  esac
}

if [ -n "$0" ] && [ x"$0" != x"-bash" ]; then
  if ! _main "$@"; then
    if [ -t 1 ]; then
      error "Build failed ..."
      debug
    else
      fail "Build failed ..."
    fi
  fi
fi
