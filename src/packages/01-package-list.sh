#!/bin/bash

echo "::group:: ===$(basename "$0")==="

# --- Базовые утилиты и консольные инструменты ---
BASE_UTILS=(
    tzdata
    eza
    man
    mc
    nano
    passwd
    bubblewrap
    which
    su
    sudo
    curl
    wget
    unzip
    util-linux
    coreutils
    iputils
    rsync
    atomic-actions
    apm
    stplr
)

# --- Пакеты для контейнеров (Docker / Podman / Flatpak и т.д.) ---
CONTAINER_PACKAGES=(
    bootc
    bootupd
    distrobox
    flatpak
    docker-engine
    podman
    containers-common
    fuse-overlayfs
    composefs
    skopeo
)

# --- Утилиты для загрузки / EFI / Boot ---
BOOT_PACKAGES=(
    efivar
    shim-unsigned
    shim-signed
    efitools
    efibootmgr
    grub
    grub-efi
    grub-btrfs
    dracut
)

# --- Ядро и связанные модули ---
KERNEL_PACKAGES=(
    kernel-image-6.12
    kernel-modules-drm-6.12
)

# --- Виртуализация и гостевые агенты (QEMU, Spice, LXD/Libvirt и т.д.) ---
VIRT_PACKAGES=(
    open-vm-tools
    qemu-guest-agent
    spice-vdagent
    virtiofsd
    libvirt
    lxd
)

# --- Системные библиотеки, инструменты и утилиты ---
SYSTEM_TOOLS=(
    firmware-linux
    fprintd
    jq
    yq
    mount
    policycoreutils
    libselinux
    losetup
    dosfstools
    e2fsprogs
    NetworkManager
    sfdisk
    bluez
    btrfs-progs
    kbd
    kbd-data
    ostree
    systemd
    chrony
    plymouth
    attr
)

# --- Графические пакеты и драйверы ---
GRAPHICS_PACKAGES=(
    mesa-dri-drivers
    glxinfo
)

# Теперь объединим всё в один список:
ALL_PACKAGES=(
    "${BASE_UTILS[@]}"
    "${CONTAINER_PACKAGES[@]}"
    "${BOOT_PACKAGES[@]}"
    "${KERNEL_PACKAGES[@]}"
    "${VIRT_PACKAGES[@]}"
    "${SYSTEM_TOOLS[@]}"
    "${GRAPHICS_PACKAGES[@]}"
)

apt-get install -y "${ALL_PACKAGES[@]}"

echo "::endgroup::"
