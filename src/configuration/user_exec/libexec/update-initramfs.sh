#!/bin/bash
set -euo pipefail

echo "::group:: ===$(basename "$0")==="

KERNEL_DIR="/usr/lib/modules"

echo "Detecting kernel version..."
KERNEL_VERSION=$(ls "$KERNEL_DIR" | sort -V | tail -n 1)

if [[ -z "$KERNEL_VERSION" ]]; then
    echo "Error: No kernel version found in $KERNEL_DIR."
    exit 1
fi

# Depmod and autoload
echo "Running depmod for kernel ${KERNEL_VERSION}..."
depmod -a -v "${KERNEL_VERSION}"

# Rebuilding initramfs
echo "Rebuilding initramfs..."
dracut --force "$KERNEL_DIR/$KERNEL_VERSION/initramfs.img" $KERNEL_VERSION

# Copy vmlinuz for bootc
cp -f "/boot/vmlinuz-$KERNEL_VERSION" "$KERNEL_DIR/$KERNEL_VERSION/vmlinuz"

echo "::endgroup::"
