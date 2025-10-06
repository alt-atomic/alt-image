#!/bin/bash
set -euo pipefail

echo "Updating the initramfs and vmlinuz..."

KERNEL_DIR="/usr/lib/modules"

echo "Detecting kernel version..."
# Find the latest kernel version by sorting
KERNEL_VERSION=$(ls "/usr/lib/modules" | sort -V | tail -n 1)

if [[ -z "$KERNEL_VERSION" ]]; then
    echo "Error: No kernel version found in $KERNEL_DIR."
    exit 1
fi

# Depmod and autoload
depmod -a -v "${KERNEL_VERSION}"

# Rebuilding initramfs
dracut --force "$KERNEL_DIR/$KERNEL_VERSION/initramfs.img" $KERNEL_VERSION

# Copy vmlinuz for bootc
cp -f "/boot/vmlinuz-$KERNEL_VERSION" "$KERNEL_DIR/$KERNEL_VERSION/vmlinuz"
