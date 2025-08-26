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

# DRIVERS=$(find "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers" \( \
#         -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/hid/*" \
#         -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/gpu/*" \
#         -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/pci/*" \
#         -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/mmc/*" \
#         -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/usb/host/*" \
#         -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/usb/storage/*" \
#         -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/nvmem/*" \
#         -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/nvme/*" \
#         -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/virtio/*" \
#         -o -path "${KERNEL_DIR}/${KERNEL_VERSION}/kernel/drivers/video/fbdev/*" \
#     \) -type f -name '*.ko*' | sed 's:.*/::')

# cat << EOF > /usr/lib/dracut/dracut.conf.d/50_kmdir.conf
# hostonly=no
# add_drivers+=" $DRIVERS "
# EOF

echo "kernel_image=$KERNEL_DIR/$KERNEL_VERSION/vmlinuz" >> /usr/lib/dracut/dracut.conf.d/95_bootc-base.conf

dracut --force \
       "$KERNEL_DIR/$KERNEL_VERSION/initramfs.img" \
       "$KERNEL_VERSION"

echo "::endgroup::"
