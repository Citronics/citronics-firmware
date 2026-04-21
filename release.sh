#!/bin/bash
set -e

# Phone is required first argument
if [ -z "${1:-}" ]; then
  echo "ERROR: Phone argument required" >&2
  echo "Usage: $0 <phone>" >&2
  echo "Example: $0 fp2" >&2
  exit 1
fi
PHONE="$1"

TAG=$(git describe --tags --exact-match)
VERSION=${TAG#v}

# Derive package name from phone's control file
PKG_NAME=$(grep '^Package:' "phones/${PHONE}/DEBIAN/control" | awk '{print $2}')

echo "Building ${PKG_NAME} ${VERSION}..."
./build-deb.sh "$PHONE"

DEB="${PKG_NAME}_${VERSION}_all.deb"
if [ ! -f "$DEB" ]; then
  echo "ERROR: Expected $DEB not found"
  exit 1
fi

echo "Creating GitHub release $TAG..."
gh release create "$TAG" "$DEB" \
  --repo Citronics/citronics-firmware \
  --title "citronics-firmware ${VERSION} (${PHONE})" \
  --notes "Release ${VERSION} for ${PHONE}"

echo "Done. Release $TAG published with $DEB"
