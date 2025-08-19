#!/bin/bash
set -euo pipefail

echo "::group:: ===$(basename "$0")==="


# Находим версию ядра
KERNEL_DIR="/usr/lib/modules"
BOOT_DIR="/boot"

echo "Detecting kernel version..."
KERNEL_VERSION=$(ls "$KERNEL_DIR" | head -n 1)

if [[ -z "$KERNEL_VERSION" ]]; then
    echo "Error: No kernel version found in $KERNEL_DIR."
    exit 1
fi

MODULES=$(find "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers" \( \
        -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/hid/*" \
        -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/gpu/*" \
        -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/pci/*" \
        -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/mmc/*" \
        -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/usb/host/*" \
        -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/usb/storage/*" \
        -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/nvmem/*" \
        -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/nvme/*" \
        -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/virtio/*" \
        -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/video/fbdev/*" \
    \) -type f -name '*.ko*' | sed 's:.*/::')

# Устанавливаем тему Plymouth перед сборкой initramfs
if [ -f /usr/share/plymouth/themes/bgrt/bgrt.plymouth ]; then
    plymouth-set-default-theme bgrt
    echo "Set bgrt theme for Plymouth"
else
    echo "Warning: No suitable Plymouth theme found, using default"
fi

dracut --force \
       --no-hostonly \
       --kver "$KERNEL_VERSION" \
       --add "qemu ostree virtiofs btrfs base overlayfs bluetooth drm plymouth crypt" \
       --add-drivers "gpio-virtio.ko i2c-virtio.ko nd_virtio.ko virtio-iommu.ko virtio_pmem.ko virtio_rpmsg_bus.ko virtio_snd.ko vmw_vsock_virtio_transport.ko vmw_vsock_virtio_transport_common.ko vp_vdpa.ko virtiofs.ko ext4 btrfs.ko ahci.ko sd_mod.ko ahci_platform.ko sd_mod.ko evdev.ko virtio_scsi.ko virtio_blk.ko virtio-rng virtio_net.ko virtio-gpu.ko virtio-mmio.ko virtio_pci.ko virtio_console.ko virtio_input.ko crc32_generic.ko ata_piix.ko $MODULES" \
       "${BOOT_DIR}/initramfs-${KERNEL_VERSION}.img"

# Копируем vmlinuz и initramfs
echo "Copying vmlinuz and initramfs..."
cp "${BOOT_DIR}/vmlinuz-${KERNEL_VERSION}" "${KERNEL_DIR}/${KERNEL_VERSION}/vmlinuz"
cp "${BOOT_DIR}/initramfs-${KERNEL_VERSION}.img" "${KERNEL_DIR}/${KERNEL_VERSION}/initramfs.img"

echo "::endgroup::"