FROM registry.altlinux.org/sisyphus/golang:latest AS atomic-actions-build

RUN apt-get update && apt-get install -y git

ENV BUILD_DIR="/tmp/atomic-actions"
ENV ACTIONS_SRC_PATH="${BUILD_DIR}/models/actions"
ENV ACTIONS_DEST_PATH=/rootfs/usr/local/share/atomic-actions/actions

RUN <<END
    set -euo pipefail
    git clone https://github.com/code-ascend/atomic-actions.git ${BUILD_DIR}

    mkdir -p \
        /rootfs/usr/local/bin \
        "${ACTIONS_DEST_PATH}"

    cd ${BUILD_DIR}
    go build -o /rootfs/usr/local/bin/atomic-actions
    chmod +x "/rootfs/usr/local/bin/atomic-actions"
    cp -r "${ACTIONS_SRC_PATH}/." "${ACTIONS_DEST_PATH}"
    find "${ACTIONS_DEST_PATH}" -type f -name "*.sh" -exec chmod +x {} \;
END

FROM ghcr.io/alt-atomic/alt-image-base:latest AS alt-image-unsquashed

# packages scripts

RUN --mount=type=bind,src=./src/packages/00-apt-prepare.sh,target=/s /s
RUN --mount=type=bind,src=./src/packages/01-package-list.sh,target=/s /s
RUN --mount=type=bind,src=./src/packages/02-apt-ending.sh,target=/s /s

# configuration scripts

COPY ./src/configuration/user_exec/systemd/system /usr/lib/systemd/system/
COPY ./src/configuration/user_exec/libexec /usr/libexec/

RUN <<END
    set -euo pipefail

    echo "SELINUX=disabled" > /etc/selinux/config

    touch /etc/sudoers.d/allow-wheel-nopass
    echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/allow-wheel-nopass

    touch /etc/vconsole.conf
    echo "KEYMAP=ruwin-Corwin_alt_sh-UTF-8" > /etc/vconsole.conf
    echo "FONT=UniCyr_8x16" > /etc/vconsole.conf

    grep -qE "^\* hard nofile 978160$" /etc/security/limits.conf || echo "* hard nofile 978160" >> /etc/security/limits.conf
    grep -qE "^\* soft nofile 978160$" /etc/security/limits.conf || echo "* soft nofile 978160" >> /etc/security/limits.conf

    systemctl enable libvirtd
    systemctl enable chrony
    systemctl enable docker.socket
    systemctl enable podman.socket

    systemctl enable brew-setup.service
    systemctl enable brew-upgrade.timer
    systemctl enable brew-update.timer
    systemctl enable update-image-task.timer

    fc-cache -fv

    chmod u+s /usr/bin/newuidmap /usr/bin/newgidmap
    chmod a+x /usr/bin/newuidmap /usr/bin/newgidmap

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    curl -o /usr/share/zoneinfo/zone.tab https://raw.githubusercontent.com/eggert/tz/main/zone.tab

    echo 'LANG=ru_RU.UTF-8' | tee /etc/locale.conf /etc/sysconfig/i18n
END

COPY ./src/source/configuration/etc/ /etc
COPY ./src/source/configuration/lib/ /lib

# make scripts

# https://github.com/Homebrew/brew/issues/19867
# RUN --mount=type=bind,src=./src/make/01-brew.sh,target=/s /s
COPY --from=atomic-actions-build /rootfs /
RUN --mount=type=bind,src=./src/make/03-alr.sh,target=/s /s
RUN --mount=type=bind,src=./src/make/04-apm.sh,target=/s /s
RUN --mount=type=bind,src=./src/make/05-clear.sh,target=/s /s

FROM scratch
COPY --from=alt-image-unsquashed / /
LABEL containers.bootc=1
CMD ["/sbin/init"]