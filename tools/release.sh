#!/bin/sh

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

TAG="${1}"

if [ "${TAG}" = "" ]; then
  TAG="${MAJOR}.${MINOR}.${PATCH}"
fi

echo "Releasing ${TAG} ..."

git-chglog --next-tag="${TAG}" --output CHANGELOG.md
github-release release \
  -u prologic \
  -r ulinux \
  -t "${TAG}" \
  -n "${TAG}" \
  -d "$(git-chglog --next-tag "${TAG}" "${TAG}" | tail -n+5)" \
  --draft
for asset in *.gz *.iso *.txt; do
  github-release upload \
    -u prologic \
    -r ulinux \
    -t "${TAG}" \
    -f "${asset}" \
    -n "${asset}" \
    -l "${asset}"
done
