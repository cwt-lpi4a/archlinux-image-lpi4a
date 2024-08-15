#!/bin/bash

## Configuration section ##

# Constants
GITHUB=https://github.com/cwt-lpi4a
DATA=/data

# Build parameters
BUILD="$(date +'%Y%m%d%H%M')"
ROOTFS=https://riscv.mirror.pkgbuild.com/images/archriscv-2024-03-30.tar.zst

# Kernel & Headers
KERNEL_REL=1
KERNEL_GIT=r277.f6b3a51da

KERNEL_PKG=linux-cwt-510-thead-lpi4a-${KERNEL_GIT}-${KERNEL_REL}-riscv64.pkg.tar.zst
KERNEL_URL=${GITHUB}/linux-cwt-thead-lpi4a/releases/download/${KERNEL_GIT}-${KERNEL_REL}/${KERNEL_PKG}

KERNEL_HEADERS_PKG=linux-cwt-510-thead-lpi4a-headers-${KERNEL_GIT}-${KERNEL_REL}-riscv64.pkg.tar.zst
KERNEL_HEADERS_URL=${GITHUB}/linux-cwt-thead-lpi4a/releases/download/${KERNEL_GIT}-${KERNEL_REL}/${KERNEL_HEADERS_PKG}

# TH1520 Firmware & LPi4A Bluetooth
REVY_MKIMG_VER=20240602

TH1520_FRMW_REL=1
TH1520_FRMW_PKG=th1520-firmware-${REVY_MKIMG_VER}-${TH1520_FRMW_REL}-riscv64.pkg.tar.zst
TH1520_FRMW_URL=${GITHUB}/th1520-firmware/releases/download/${REVY_MKIMG_VER}-${TH1520_FRMW_REL}/${TH1520_FRMW_PKG}

LPi4A_BLTH_REL=1
LPi4A_BLTH_PKG=lpi4a-bt-${REVY_MKIMG_VER}-${LPi4A_BLTH_REL}-riscv64.pkg.tar.zst
LPi4A_BLTH_URL=${GITHUB}/lpi4a-bt/releases/download/${REVY_MKIMG_VER}-${LPi4A_BLTH_REL}/${LPi4A_BLTH_PKG}

# TH1520 Boot Firmware & OpenSBI
BOOT_FRMW_REL=1
BOOT_FRMW_GIT=r9.bc5d334

BOOT_FRMW_PKG=th1520-boot-firmware-${BOOT_FRMW_GIT}-${BOOT_FRMW_REL}-riscv64.pkg.tar.zst
BOOT_FRMW_URL=${GITHUB}/th1520-boot-firmware/releases/download/${BOOT_FRMW_GIT}-${BOOT_FRMW_REL}/${BOOT_FRMW_PKG}

VND_OPENSBI_PKG=th1520-vendor-opensbi-${BOOT_FRMW_GIT}-${BOOT_FRMW_REL}-riscv64.pkg.tar.zst
VND_OPENSBI_URL=${GITHUB}/th1520-boot-firmware/releases/download/${BOOT_FRMW_GIT}-${BOOT_FRMW_REL}/${VND_OPENSBI_PKG}

# TH1520 Imagination PowerVR GPU
GPU_REL=2
GPU_GIT=r4.8d02e2c
GPU_PKG=th1520-img-gpu-${GPU_GIT}-${GPU_REL}-riscv64.pkg.tar.zst
GPU_URL=${GITHUB}/th1520-img-gpu/releases/download/${GPU_GIT}-${GPU_REL}/${GPU_PKG}

# TH1520 DDX
DDX_REL=1
DDX_GIT=r27.e3b21e5
DDX_PKG=xf86-video-thead-${DDX_GIT}-${DDX_REL}-riscv64.pkg.tar.zst
DDX_URL=${GITHUB}/xf86-video-thead/releases/download/${DDX_GIT}-${DDX_REL}/${DDX_PKG}

# TH1520 DDK117
DDK_REL=1
DDK_VER=21.2.1+2revyos2+glvnd
DDK_PKG=mesa-pvr-ddk117-${DDK_VER}-${DDK_REL}-riscv64.pkg.tar.zst
DDK_URL=${GITHUB}/mesa-pvr-ddk117/releases/download/${DDK_VER}-${DDK_REL}/${DDK_PKG}

# TH1520 VPU
VPU_REL=1
VPU_GIT=r4.b9baefa
VPU_PKG=th1520-vpu-${VPU_GIT}-${VPU_REL}-riscv64.pkg.tar.zst
VPU_URL=${GITHUB}/th1520-vpu/releases/download/${VPU_GIT}-${VPU_REL}/${VPU_PKG}

# TH1520 NPU
NPU_REL=3
NPU_GIT=r2.492b7e6
NPU_PKG=th1520-npu-${NPU_GIT}-${NPU_REL}-riscv64.pkg.tar.zst
NPU_URL=${GITHUB}/th1520-npu/releases/download/${NPU_GIT}-${NPU_REL}/${NPU_PKG}

# Target packages
PACKAGES="base btrfs-progs chrony clinfo compsize dosfstools mtd-utils networkmanager openssh rng-tools\
          smartmontools sudo terminus-font vi vulkan-tools wireless-regdb zram-generator zstd iptables-nft\
	  linux-firmware apparmor python-notify2 python-psutil"

## End configuration section ##

## Build section ##

# Set locale to POSIX standards-compliant
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Remember current directory as working directory
WORK_DIR=$(pwd)

# Install required tools on the builder box
sudo pacman -S wget arch-install-scripts zstd util-linux btrfs-progs dosfstools git xz --needed --noconfirm

# Set wget options
WGET="wget --progress=bar -c -O"

# Output
IMAGE=${DATA}/ArchLinux-LPi4A_${KERNEL_GIT}-${KERNEL_REL}-${BUILD}.img
TARGET=${DATA}/${BUILD}
PKGS=${DATA}/pkgs

# Prepare build directory
ZR=$(sudo zramctl -f --size=10G)
sudo mkfs.ext4 ${ZR}
sudo mount ${ZR} ${DATA}
sudo mkdir -p ${DATA}
sudo chown -R $(id -u):$(id -g) ${DATA}
mkdir -p ${PKGS}

# Download rootfs
${WGET} ${DATA}/rootfs.tar.zst ${ROOTFS}

# Download -cwt kernel
${WGET} ${PKGS}/${KERNEL_PKG} ${KERNEL_URL}
${WGET} ${PKGS}/${KERNEL_HEADERS_PKG}-headers-${KERNEL_REL}-riscv64.pkg.tar.zst ${KERNEL_HEADERS_URL}

# Download TH1520 firmware and bluetooth
${WGET} ${PKGS}/${TH1520_FRMW_PKG} ${TH1520_FRMW_URL}
${WGET} ${PKGS}/${LPi4A_BLTH_PKG} ${LPi4A_BLTH_URL}

# Download TH1520 boot firmware & vendor OpenSBI
${WGET} ${PKGS}/${BOOT_FRMW_PKG} ${BOOT_FRMW_URL}
${WGET} ${PKGS}/${VND_OPENSBI_PKG} ${VND_OPENSBI_URL}

# Download TH1520 IMG GPU driver
${WGET} ${PKGS}/${GPU_PKG} ${GPU_URL}

# Download TH1520 DDX
${WGET} ${PKGS}/${DDX_PKG} ${DDX_URL}

# Download TH1520 DDK117
${WGET} ${PKGS}/${DDK_PKG} ${DDK_URL}

# Download TH1520 VPU
${WGET} ${PKGS}/${VPU_PKG} ${VPU_URL}

# Download TH1520 NPU
${WGET} ${PKGS}/${NPU_PKG} ${NPU_URL}

# Setup disk image
cd ${WORK_DIR}
rm -f ${IMAGE}
fallocate -l 7G ${IMAGE}
LOOP=$(sudo losetup -f -P --show "${IMAGE}")
cat parts.txt | sed -e "s#LOOP_DEVICE#${LOOP}#g" | sudo sfdisk ${LOOP}

# Format boot partition
sudo mkfs.ext4 -L BOOT ${LOOP}p2

# Set up a Linux swap area
sudo mkswap -L SWAP ${LOOP}p3

# Format root partition
sudo mkfs.btrfs --csum xxhash -L LPi4A ${LOOP}p4

# Setup target mount
sudo mkdir -p ${TARGET}
sudo mount -o discard=async,compress=lzo ${LOOP}p4 ${TARGET}
VOLUMES="@ @home @pkg @log @.snapshots"
for volume in ${VOLUMES}; do
	sudo btrfs subvolume create ${TARGET}/${volume}
done
sudo umount ${TARGET}

# Remount all subvolumes
VOLUMES="@:${TARGET} @home:${TARGET}/home\
         @log:${TARGET}/var/log @.snapshots:${TARGET}/.snapshots"
for volume in ${VOLUMES}; do
	IFS=: read -r subvol mnt <<< ${volume}
	sudo mkdir -p ${mnt}
	sudo mount -o discard=async,compress=lzo,subvol=${subvol} ${LOOP}p4 ${mnt}
done

# Mount packages cache as tmpfs
sudo mkdir -p ${TARGET}/var/cache/pacman/pkg
sudo mount -t tmpfs tmpfs ${TARGET}/var/cache/pacman/pkg

# Mount /boot and install StarFive u-boot config
sudo mkdir -p ${TARGET}/boot
sudo mount -o discard ${LOOP}p2 ${TARGET}/boot
sudo mkdir -p ${TARGET}/boot/extlinux
sudo install -o root -g root -m 644 configs/extlinux.conf ${TARGET}/boot/extlinux/extlinux.conf

# Extract rootfs to target mount
sudo tar -C ${TARGET} --zstd -xf ${DATA}/rootfs.tar.zst

# Copy kernel and other packages
sudo mkdir -p ${TARGET}/root/pkgs
sudo cp ${DATA}/pkgs/* ${TARGET}/root/pkgs

# Disable microcode hook
sudo install -o root -g root -D -m 644 configs/no-microcode-hook.conf ${TARGET}/etc/mkinitcpio.conf.d/no-microcode-hook.conf

# Add required modules
sudo install -o root -g root -D -m 644 configs/thead.conf ${TARGET}/etc/mkinitcpio.conf.d/thead.conf

# Update and install packages via arch-chroot
sudo arch-chroot ${TARGET} pacman -Syu --noconfirm
sudo arch-chroot ${TARGET} pacman -S ${PACKAGES} --needed --noconfirm --ask=4
sudo arch-chroot ${TARGET} bash -c "pacman -U /root/pkgs/*.pkg.tar.zst --noconfirm"
sudo arch-chroot ${TARGET} pacman -Sc --noconfirm

# Install default configs
sudo install -o root -g root -m 644 configs/fstab ${TARGET}/etc/fstab
sudo install -o root -g root -m 644 configs/hostname ${TARGET}/etc/hostname
sudo install -o root -g root -m 644 configs/vconsole.conf ${TARGET}/etc/vconsole.conf
sudo install -o root -g root -m 644 configs/zram-generator.conf ${TARGET}/etc/systemd/zram-generator.conf

# Create user
sudo arch-chroot ${TARGET} groupadd user
sudo arch-chroot ${TARGET} useradd -g user --btrfs-subvolume-home -c "Arch User" -m user
sudo arch-chroot ${TARGET} /bin/bash -c "echo 'user:user' | chpasswd -c SHA512"
sudo arch-chroot ${TARGET} /bin/bash -c "echo 'user ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/user"

# Enable services
SERVICES="NetworkManager chronyd rngd smartd sshd apparmor"
for service in ${SERVICES}; do
	sudo arch-chroot ${TARGET} systemctl enable ${service}
done

## End build section ##

## Clean up ##
echo -e "\nTo clean up run: ./cleanup.sh ${TARGET} ${LOOP}"

