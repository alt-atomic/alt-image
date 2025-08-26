#!/bin/bash
set -euo pipefail

echo "::group:: ===$(basename "$0")==="

KERNEL_DIR="/usr/lib/modules"
KERNEL_VERSION=$(uname -r)

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

# TODO: Package file
UPDATE_INITRAMFS_FILE=/usr/libexec/update-initramfs
cat << EOF > $UPDATE_INITRAMFS_FILE
#!/usr/bin/bash
# File helper for rebuilding initramfs
dracut --force \
       "$KERNEL_DIR/$KERNEL_VERSION/initramfs.img" \
       "$KERNEL_VERSION"

# Copy vmlinuz for bootc
echo "Copying vmlinuz and initramfs..."
cp -f "/boot/vmlinuz-$KERNEL_VERSION" "$KERNEL_DIR/$KERNEL_VERSION/vmlinuz"
EOF

chmod u+x $UPDATE_INITRAMFS_FILE

$UPDATE_INITRAMFS_FILE

echo "::endgroup::"
