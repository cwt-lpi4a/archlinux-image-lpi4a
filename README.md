# Arch Linux SD Card Image for LicheePi 4A
Build script to create the Arch Linux image for [LicheePi 4A](https://sipeed.com/licheepi4a).

## License
This build script is released under the MIT License. See the [LICENSE](LICENSE) file for details.

## Image Details
- **File format**: Zstd compressed raw disk image (.img.zst)
- **Target**: SD card boot
- **Compatibility**: LicheePi 4A board

## Major Components

### Base System
- Arch RISC-V rootfs
  - Source: https://riscv.mirror.pkgbuild.com/

### Kernel
- Based on RevyOS's [thead-kernel](https://github.com/revyos/thead-kernel)
- Includes patches and configuration from [cwt-lpi4a/linux-cwt-thead-lpi4a](https://github.com/cwt-lpi4a/linux-cwt-thead-lpi4a)

### Additional Packages
- Drivers and packages from RevyOS, rebuilt and repackaged for Arch Linux
- PKGBUILD files available at: https://github.com/cwt-lpi4a

## Installation
1. Download the .img.zst file
2. Write the image to an SD card using a tool like `dd` (decompress it first) or Etcher
3. Insert the SD card into your LicheePi 4A board and boot

## Login Information
- **Username**: `user`
- **Password**: `user`
- **Privileges**: This user has sudo access

## Notes
- This image is specifically configured for SD card boot on the LicheePi 4A board
- All components have been integrated and tested for compatibility
- Users are encouraged to check the linked repositories for detailed change logs and additional information
