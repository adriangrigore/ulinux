#!/bin/sh

BINTRAY_USER=prologic
BINTRAY_REPO=uLinux
BINTRAY_KEY="${BINTRAY_KEY}"

log() {
  printf "%s\n" "$1"
}

error() {
  printf "ERROR: %s\n" "$1"
}

warn() {
  printf "WARN: %s\n" "$1"
}

fail() {
  printf "FAIL: %s\n" "$1"
}

package_exists() {
  name="$1"
  curl \
    -u "${BINTRAY_USER}:${BINTRAY_KEY}" \
    "https://api.bintray.com/packages/${BINTRAY_USER}/${BINTRAY_REPO}/$name"
}

create_package() {
  name="${1}"

  data="$(mktemp -t pkg-pub-XXXXXX)"

  cat > "$data" << EOF
{
  "name": "$name",
  "desc": "auto",
  "desc_url": "auto",
  "labels": ["pkg", "$name]
}
EOF

  curl \
    -X POST \
    -d "@${data}" \
    -u "${BINTRAY_USER}:${BINTRAY_KEY}" \
    "https://api.bintray.com/packages/${BINTRAY_USER}/${BINTRAY_REPO}"
}

upload_package() {
  f="${1}"
  name="${2}"
  version="${3}"

  curl \
    -T "$f" \
    -u "${BINTRAY_USER}:${BINTRAY_KEY}" \
    "https://api.bintray.com/content/${BINTRAY_USER}/${BINTRAY_REPO}/$name/$version/${name}%23${version}.tar.gz"
}

_main() {
  if [ -z "$BINTRAY_KEY" ]; then
    fail "BINTRAY_KEY is not"
    exit 1
  fi

  f="${1}"
  base="$(basename "$f")"
  noext="${base%*.tar.gz*}"
  name="${noext%#*}"
  version="${noext#*#}"

  printf "publishing package %s v%s ...\n" "${name}" "${version}"

  if ! package_exists "$name"; then
    create_package "$name"
  fi
  upload_package "$f" "$name" "$version"
}

if [ -n "$0" ] && [ x"$0" != x"-bash" ]; then
  _main "$@"
fi
