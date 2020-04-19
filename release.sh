#!/bin/sh

set -e

. ./functions.sh

TAG="${TAG}"

generate_next_tag() {
  progress "Generating next tag"

  # Get the highest tag number
  VERSION="$(git describe --abbrev=0 --tags)"
  VERSION=${VERSION:-'0.0.0'}

  # Get number parts
  MAJOR="${VERSION%%.*}"
  VERSION="${VERSION#*.}"
  MINOR="${VERSION%%.*}"
  VERSION="${VERSION#*.}"
  PATCH="${VERSION%%.*}"
  VERSION="${VERSION#*.}"

  # Increase version
  PATCH=$((PATCH + 1))

  if [ "${TAG}" = "" ]; then
    TAG="${MAJOR}.${MINOR}.${PATCH}"
  fi
}

generate_changelog() {
  progress "Generating chnagelog"
  (
    git-chglog --next-tag="${TAG}" --output CHANGELOG.md
    git ci -a -m "Release ${TAG}"
    git push -q
  ) >&2
}

create_draft_release() {
  progress "Creating draft release"
  (
    github-release release \
      -u prologic \
      -r ulinux \
      -t "${TAG}" \
      -n "${TAG}" \
      -d "$(git-chglog --next-tag "${TAG}" "${TAG}" | tail -n+5)" \
      --draft
  ) >&2
}

build_ulinux() {
  progress "Building uLinux"
  (
    make clean
    make up-to-date
    make build
  ) >&2
}

prepare_assets() {
  progress "Preparing assets"
  (
    sha256sum ./*.gz ./*.iso > sha256sums.txt
    gpg --detach-sign sha256sums.txt
  ) >&2
}

upload_assets() {
  progress "Uploading assets"
  (
    for asset in *.gz *.iso *.txt *.sig; do
      github-release upload \
        -u prologic \
        -r ulinux \
        -t "${TAG}" \
        -f "${asset}" \
        -n "${asset}" \
        -l "${asset}"
    done
  ) >&2
}

steps="generate_next_tag generate_changelog create_draft_release"
steps="$steps build_ulinux prepare_assets upload_assets"

_main() {
  for step in $steps; do
    if ! run "$step"; then
      fail "Release failed"
    fi
  done

  echo "🎉 All Done!"
}

if [ -n "$0" ] && [ x"$0" != x"-bash" ]; then
  if ! _main "$@"; then
    fail "Release failed"
  fi
fi
