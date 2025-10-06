#!/bin/bash
set -euo pipefail

echo "::group:: ===$(basename "$0")==="

KERNEL_PACKAGES=(
    kernel-image-6.12
    kernel-modules-drm-6.12
)

/usr/libexec/update-bootc-kernel.sh "${KERNEL_PACKAGES[@]}"

echo "::endgroup::"