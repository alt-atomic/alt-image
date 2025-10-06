#!/bin/bash
set -euo pipefail

PACKAGES=("$@")

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    echo "Error: No kernel packages specified."
    exit 1
fi

echo "Installing kernel packages: ${PACKAGES[*]}"

echo "Removing old kernels..."
INSTALLED_KERNELS=$(rpm -qa | grep -E '^kernel-(image|modules)-' || true)
if [[ -n "$INSTALLED_KERNELS" ]]; then
    echo "Found installed kernel packages:"
    echo "$INSTALLED_KERNELS"
    apt-get remove --purge -y $INSTALLED_KERNELS
else
    echo "No installed kernel packages found"
fi

echo "Cleaning kernel modules directory..."
rm -rf /usr/lib/modules/*

apt-get update
apt-get install -y "${PACKAGES[@]}"

/usr/libexec/update-initramfs.sh
