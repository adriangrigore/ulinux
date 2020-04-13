#!/bin/sh

# This file is included by download.sh & build.sh

set -e

log() {
  printf "%s\n" "$1"
}

error() {
  log "ERROR: ${1}"
}

fail() {
  log "FATAL: ${1}"
  exit 1
}

debug() {
  log "Dropping into a shell for debugging ..."
  exec /bin/sh
}

config() {
  if grep "CONFIG_$2" .config; then
    sed -i "s|.*CONFIG_$2.*|CONFIG_$2=$1|" .config
  else
    echo "CONFIG_$2=$1" >> .config
  fi
}

fnmatch() {
  case "$2" in
    $1)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
