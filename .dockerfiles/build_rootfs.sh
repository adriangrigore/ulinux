#!/bin/sh

get_latest_release() {
  curl -sL https://api.github.com/repos/prologic/ulinux/releases | # Get releases from GitHub api
    jq -r '.[] | .tag_name' |                                      # Extract tag names
    sort -r |                                                      # Sort in reverse order (highest first)
    head -n 1                                                      # Extract the latest released tag name
}

extract_rootfs() {
  f="$1"
  d="$2"
  mkdir -p "$d"
  cd "$d" || return 1
  zcat < "$f" | cpio -idm
  cd - || return 1
}

_main() {
  if [ ! -f rootfs.gz ]; then
    latest_version="$(get_latest_release prologic/ulinux)"
    wget -q -O rootfs.gz \
      "https://github.com/prologic/ulinux/releases/download/$latest_version/rootfs.gz"
  fi

  extract_rootfs "$(realpath rootfs.gz)" /rootfs
}

if [ -n "$0" ] && [ x"$0" != x"-bash" ]; then
  _main "$@"
fi
