#!/bin/sh

set -e

. ./functions.sh

TAG="${TAG}"

generate_next_tag() {
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
  printf "Creating chnagelog for %s ....\n" "${TAG}"

  git-chglog --next-tag="${TAG}" --output CHANGELOG.md
  git ci -a -m "Release ${TAG}"
  git push
}

create_draft_release() {
  printf "Creating draft release for %s ...\n" "${TAG}"

  github-release release \
    -u prologic \
    -r ulinux \
    -t "${TAG}" \
    -n "${TAG}" \
    -d "$(git-chglog --next-tag "${TAG}" "${TAG}" | tail -n+5)" \
    --draft
}

build_ulinux() {
  make clean
  make up-to-date
  make build
  printf "Calculating SHA256SUMS ..."
  sha256sum ./*.gz ./*.iso > sha256sums.txt
  printf "Signing SHA256SUMS ..."
  gpg --detach-sign sha256sums.txt
}

upload_assets() {
  for asset in *.gz *.iso *.txt *.sig; do
    github-release upload \
      -u prologic \
      -r ulinux \
      -t "${TAG}" \
      -f "${asset}" \
      -n "${asset}" \
      -l "${asset}"
  done
}

steps="generate_next_tag generate_changelog create_draft_release"
steps="$steps build_ulinux upload_assets"

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
