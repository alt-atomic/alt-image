#!/bin/bash
set -euo pipefail

echo "::group:: ===$(basename "$0")==="

KERNEL_DIR="/usr/lib/modules"

echo "Detecting kernel version..."
# uname is not an option
KERNEL_VERSION=$(ls "$KERNEL_DIR" | head -n 1)

if [[ -z "$KERNEL_VERSION" ]]; then
    echo "Error: No kernel version found in $KERNEL_DIR."
    exit 1
fi

# TODO: Package file
UPDATE_INITRAMFS_FILE=/usr/libexec/update-initramfs
cat << EOF > $UPDATE_INITRAMFS_FILE
#!/usr/bin/bash

set -ex

# File helper for rebuilding initramfs
dracut --force "$KERNEL_DIR/$KERNEL_VERSION/initramfs.img" $KERNEL_VERSION
EOF

chmod u+x $UPDATE_INITRAMFS_FILE

$UPDATE_INITRAMFS_FILE

# Copy vmlinuz for bootc
cp -f "/boot/vmlinuz-$KERNEL_VERSION" "$KERNEL_DIR/$KERNEL_VERSION/vmlinuz"

echo "::endgroup::"
