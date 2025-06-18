#!/bin/bash
set -e

echo "::group:: ===$(basename "$0")==="

#mkdir -p /var/root /var/home /var/mnt /var/opt /var/srv /etc/atomic
mkdir -p /var/root /var/home /var/mnt /var/srv /etc/atomic
rm -rf /mnt && ln -s var/mnt /mnt
#rm -rf /opt && ln -s var/opt /opt
rm -rf /srv && ln -s var/srv /srv
rm -rf /media && ln -s run/media /media

rm -rf /root && ln -s var/root /root
rm -rf /home && ln -s var/home /home
ln -s sysroot/ostree /ostree

rm -f /etc/fstab
mkdir -p /usr/lib/bootc/kargs.d/
#mkdir /sysroot
cp -a /src/source/bootupd/ /usr/lib/
mkdir -p /usr/local/bin
mkdir -p /usr/lib/ostree

echo "[composefs]" > /usr/lib/ostree/prepare-root.conf
echo "enabled = no" >> /usr/lib/ostree/prepare-root.conf
echo "[sysroot]" > /usr/lib/ostree/prepare-root.conf
echo "readonly = true" >> /usr/lib/ostree/prepare-root.conf

# Отключаем SELINUX
echo "SELINUX=disabled" > /etc/selinux/config

# Создаём файл /etc/sudoers.d/allow-wheel-nopass если его нет
touch /etc/sudoers.d/allow-wheel-nopass
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/allow-wheel-nopass

# Настройка vconsole
touch /etc/vconsole.conf
echo "KEYMAP=ruwin-Corwin_alt_sh-UTF-8" > /etc/vconsole.conf
echo "FONT=UniCyr_8x16" > /etc/vconsole.conf

# Включаем сервис ostree-remount
mkdir -p /etc/systemd/system/local-fs.target.wants/
ln -s /usr/lib/systemd/system/ostree-remount.service /etc/systemd/system/local-fs.target.wants/ostree-remount.service

# копируем службы
cp /src/configuration/user_exec/systemd/system/* /usr/lib/systemd/system/

# копируем скрипты
cp /src/configuration/user_exec/libexec/* /usr/libexec/

# Включаем сервисы
systemctl enable NetworkManager
systemctl enable libvirtd
systemctl enable chrony
systemctl enable docker.socket
systemctl enable podman.socket
systemctl enable sync-users.service
systemctl enable sync-directory.service
systemctl enable update-image-task.timer
systemctl enable tmp.mount

# Расширение лимитов на число открытых файлов для всех юзеров. (при обновлении системы открывается большое число файлов/слоев)
grep -qE "^\* hard nofile 978160$" /etc/security/limits.conf || echo "* hard nofile 978160" >> /etc/security/limits.conf
grep -qE "^\* soft nofile 978160$" /etc/security/limits.conf || echo "* soft nofile 978160" >> /etc/security/limits.conf

# Синхронизируем файлы
rsync -av --progress /src/source/configuration/etc/ /etc/
rsync -av --progress /src/source/configuration/lib/ /lib/
rsync -av --progress /src/source/configuration/usr/ /usr/

# Обновление шрифтов
fc-cache -fv

# Меняем доступ к файлам
chmod u+s /usr/bin/newuidmap /usr/bin/newgidmap
chmod a+x /usr/bin/newuidmap /usr/bin/newgidmap

# Репозиторий flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Заберем полный zoneinfo так как пакет tzdata его не предоставляет
curl -o /usr/share/zoneinfo/zone.tab https://raw.githubusercontent.com/eggert/tz/main/zone.tab

# Локаль
echo 'LANG=ru_RU.UTF-8' | tee /etc/locale.conf /etc/sysconfig/i18n

echo "::endgroup::"
