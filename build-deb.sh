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

# Validate phone directory exists
if [ ! -d "phones/${PHONE}" ]; then
  echo "ERROR: Unknown phone '${PHONE}'. No directory phones/${PHONE}/ found." >&2
  echo "Available phones:" >&2
  ls phones/ 2>/dev/null | sed 's/^/  - /' >&2
  exit 1
fi

TAG=$(git describe --tags --exact-match 2>/dev/null) || {
  echo "ERROR: No git tag found on current commit. Create a tag first: git tag v1.0" >&2
  exit 1
}
VERSION=${TAG#v}

# Derive package name from phone's control file
PKG_NAME=$(grep '^Package:' "phones/${PHONE}/DEBIAN/control" | awk '{print $2}')
PKG_DIR="${PKG_NAME}"
FIRMWARE_DIR="${PKG_DIR}/lib/firmware"

# Set up build directory with DEBIAN from phone template
rm -rf "${PKG_DIR}"
mkdir -p "${PKG_DIR}/DEBIAN"
mkdir -p "${FIRMWARE_DIR}"
cp "phones/${PHONE}/DEBIAN/control" "${PKG_DIR}/DEBIAN/control"

# Source phone-specific firmware copy operations
# shellcheck source=/dev/null
source "phones/${PHONE}/sources.conf"
copy_firmware "${FIRMWARE_DIR}"

# Set correct permissions
find "${FIRMWARE_DIR}" -type f -exec chmod 644 {} \;

sed -i "s/^Version: .*/Version: $VERSION/" "${PKG_DIR}/DEBIAN/control"

# Build .deb package
dpkg-deb --build "${PKG_DIR}" "${PKG_NAME}_${VERSION}_all.deb"

echo "Built package: ${PKG_NAME}_${VERSION}_all.deb"
