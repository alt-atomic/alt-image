#!/bin/bash

echo "::group:: ===$(basename "$0")==="

# --- Базовые утилиты и консольные инструменты ---
BASE_UTILS=(
    apm
    bash-completion
    bubblewrap
    coreutils
    curl
    doas
    eza
    fastfetch
    iputils
    man
    mc
    nano
    passwd
    rsync
    shadow-change
    starship
    stplr
    su
    tzdata
    unzip
    util-linux
    vim-minimal
    wget
    which
    zram-generator
)

# --- Пакеты для контейнеров (Docker / Podman / Flatpak и т.д.) ---
CONTAINER_PACKAGES=(
    bootc
    bootupd
    composefs
    containers-common
    docker-engine
    flatpak
    flatpak-repo-flathub
    fuse-overlayfs
    podman
    skopeo
)

# --- Утилиты для загрузки / EFI / Boot ---
BOOT_PACKAGES=(
    cryptsetup
    dracut
    efibootmgr
    efitools
    efivar
    grub
    grub-btrfs
    grub-efi
    alt-uefi-certs
    shim-signed
    shim-unsigned
)

# --- Ядро и связанные модули ---
KERNEL_PACKAGES=(
    kernel-image-6.12
    kernel-modules-drm-6.12
)

# --- Виртуализация и гостевые агенты (QEMU, Spice, LXD/Libvirt и т.д.) ---
VIRT_PACKAGES=(
    libvirt
    lxd
    open-vm-tools
    qemu-guest-agent
    spice-vdagent
    virtiofsd
)

# --- Системные библиотеки, инструменты и утилиты ---
SYSTEM_TOOLS=(
    attr
    bluez
    btrfs-progs
    chrony
    dosfstools
    e2fsprogs
    firmware-linux
    fprintd
    jq
    kbd
    kbd-data
    libselinux
    losetup
    mount
    NetworkManager
    ostree
    plymouth
    plymouth-theme-bgrt
    policycoreutils
    sfdisk
    systemd
    yq
)

# --- Графические пакеты и драйверы ---
GRAPHICS_PACKAGES=(
    glxinfo
    mesa-dri-drivers
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
