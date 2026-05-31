#!/bin/bash
set -e

TAG=$(git describe --tags --exact-match 2>/dev/null) || {
  echo "ERROR: No git tag on current commit. Tag first: git tag v1.1" >&2
  exit 1
}
VERSION=${TAG#v}

echo "Building citronics-firmware $VERSION for all boards..."

ASSETS=""
for PHONE_DIR in phones/*/; do
  PHONE=$(basename "$PHONE_DIR")
  echo "Building $PHONE..."
  ./build-deb.sh "$PHONE"
  PKG_NAME=$(grep '^Package:' "phones/${PHONE}/DEBIAN/control" | awk '{print $2}')
  DEB="${PKG_NAME}_${VERSION}_all.deb"
  if [ ! -f "$DEB" ]; then
    echo "ERROR: Expected $DEB not found after build" >&2
    exit 1
  fi
  ASSETS="$ASSETS $DEB"
done

echo "All boards built. Assets:$ASSETS"
echo "Creating GitHub release $TAG..."
# shellcheck disable=SC2086
gh release create "$TAG" $ASSETS \
  --repo Citronics/citronics-firmware \
  --title "citronics-firmware $VERSION" \
  --notes "Firmware packages for all boards — version $VERSION"

echo "Done. Release $TAG published."
