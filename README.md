# Citronics Firmware Packaging

Firmware packaging for Citronics boards. This repository packages proprietary firmware blobs as `linux-firmware-lime-<board>` Debian packages.

## Repository Structure

- `phones/`: Contains device-specific firmware and metadata.
  - `<board>/DEBIAN/control`: Debian package metadata template.
  - `<board>/sources.conf`: Script sourcing firmware file locations.
- `build-deb.sh`: Script to package firmware into a `.deb` file.
- `release.sh`: Script to handle GitHub releases.

## Building a Firmware Package

To build a firmware package, you must first tag the repository with a version.

```bash
git tag v1.0
./build-deb.sh fp3
```

This produces a file named `linux-firmware-lime-fp3_<version>_all.deb`.

## Releasing

1. Tag the commit:
   ```bash
   git tag v1.1
   ```
 2. Run the release script — it builds all boards and creates one GitHub Release:
   ```bash
   ./release.sh
   ```
3. Trigger the [deb-packages](https://github.com/Citronics/deb-packages) CI workflow to update the APT repository.

## Adding Firmware for a New Board

1. Create a directory `phones/<board>/`.
2. Add a `DEBIAN/control` file with the package metadata.
3. Create a `sources.conf` file defining a `copy_firmware` function that copies the necessary blobs to the target directory.

## Links

- [deb-packages](https://github.com/Citronics/deb-packages): APT repository management — live at `https://citronics.github.io/deb-packages/`.
- [debos-citronics](https://github.com/Citronics/debos-citronics): OS image builder.
