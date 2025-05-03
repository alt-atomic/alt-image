ARG SISYPHUS_DATE="2025/03/30"

FROM registry.altlinux.org/sisyphus/base:latest AS base-image

FROM base-image AS base
RUN apt-get update && apt-get dist-upgrade -y

FROM base AS kernel-minimal-build
RUN apt-get install -y \
        kernel-image-6.12 \
        composefs \
        dracut \
        ostree \
        systemd
RUN <<END
    set -euo pipefail
    KERNEL_VERSION=$(ls /usr/lib/modules | head -n 1)
    if [[ -z "$KERNEL_VERSION" ]]; then
        echo "Error: No kernel version found in $KERNEL_DIR."
        exit 1
    fi
    dracut --force \
            --no-hostonly \
            --kver "$KERNEL_VERSION" \
            --add "ostree"
          
    cp "/boot/vmlinuz-${KERNEL_VERSION}"        "/usr/lib/modules/${KERNEL_VERSION}/vmlinuz"
    cp "/boot/initramfs-${KERNEL_VERSION}.img"  "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"
END

FROM base AS base-deps
RUN apt-get install -y \
        rsync \
        systemd \
        bootupd \
        grub-efi \
        grub-pc \
        sfdisk \
        bootc

FROM base-deps AS ostree-prepared-base
RUN --mount=type=bind,src=./src/configuration,target=/src <<END
    set -euo pipefail

    mkdir /sysroot

    mkdir -p \
        /var/root \
        /var/home \
        /var/mnt \
        /var/srv \
        /etc/atomic \
        /usr/local/bin \
        /usr/lib/ostree \
        /usr/lib/bootc/kargs.d/

    chown 700 /root

    rm -rf /mnt && ln -s var/mnt /mnt
    rm -rf /srv && ln -s var/srv /srv
    rm -rf /media && ln -s run/media /media
    rm -rf /root && ln -s var/root /root
    rm -rf /home && ln -s var/home /home

    rm -f /etc/fstab
    ln -s sysroot/ostree /ostree

    cp /src/prepare-root.conf /usr/lib/ostree/prepare-root.conf
    cp -a /src/configuration/usr/ /usr/
    cp -a /src/systemd/system/* /usr/lib/systemd/system/
    cp -a /src/libexec/* /usr/libexec/
    chmod +x /usr/libexec/check_user_and_group.sh
    chmod +x /usr/libexec/check_var_directory.sh
    chmod +x /usr/libexec/init-ostree.sh
    chmod +x /usr/libexec/update-system.sh

    mkdir -p /etc/systemd/system/local-fs.target.wants/
    ln -s /usr/lib/systemd/system/ostree-remount.service /etc/systemd/system/local-fs.target.wants/ostree-remount.service
    
    systemctl enable \
        tmp.mount \
        sync-users.service \
        sync-directories.service
END

FROM kernel-minimal-build AS kernel

FROM scratch AS bootupd-files
COPY ./src/bootupd /usr/lib/bootupd

FROM scratch AS branding-files
COPY ./src/branding /

FROM ostree-prepared-base AS alt-atomic-base-unsquashed

COPY --from=bootupd-files /usr/lib/bootupd /usr/lib/bootupd
COPY --from=kernel /usr/lib/modules /usr/lib/modules

RUN <<END
    set -euo pipefail

    # Since we use network updates, it looks justified.
    apt-get install -y NetworkManager
    systemctl enable NetworkManager

    mkdir -p /usr/share/rpm
    rsync -aA /var/lib/rpm/ /usr/share/rpm/
    rm -rf /var/lib/rpm && ln -s ../../usr/share/rpm /var/lib/rpm

    rm -f \
        /var/cache/apt/archives/*.rpm \
        /var/cache/apt/*.bin \
        /var/lib/apt/lists/*.*
    
    rm -rf /etc/apt        
END
COPY --from=base-image /etc/apt /etc/apt
COPY --from=branding-files / /

FROM scratch AS alt-atomic-base
COPY --from=alt-atomic-base-unsquashed / /
LABEL ostree.bootable=1
