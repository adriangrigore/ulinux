#!/bin/sh

if [ -n "$1" ]; then
  TAG="${1}"
else
  TAG="$(git describe --abbrev=0 --tags)"
fi

if [ -z "$TAG" ]; then
  printf "No tag specified or no latest tag found"
  exit 1
fi

for asset in *.gz *.iso *.txt *.sig; do
  github-release upload \
    -u prologic \
    -r ulinux \
    -t "${TAG}" \
    -f "${asset}" \
    -n "${asset}" \
    -l "${asset}"
done
