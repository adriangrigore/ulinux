#!/bin/sh

set -e

# shellcheck source=download.sh
. download.sh

# shellcheck source=build.sh
. build.sh

_main() {
  case "${1}" in
    build)
      build_all
      ;;
    download)
      download_all
      ;;
    repack)
      repack
      ;;
    *)
      download_all
      build_all
      ;;
  esac
}

_main "${@}"
