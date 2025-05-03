#!/usr/bin/env bash

# Данный скрипт устанавливает приложения Flatpak в пространство пользователя, срабатывает один раз (или по версии).
GROUP_SETUP_VER=1
GROUP_SETUP_VER_FILE="$HOME/.local/share/flatpak-user-install"

if [ "$UID" -lt 1000 ]; then
    echo "Not a valid user."
    exit 0
fi

# Проверяем выполнение
if [ -f "$GROUP_SETUP_VER_FILE" ]; then
    GROUP_SETUP_VER_RAN="$(cat "$GROUP_SETUP_VER_FILE")"
else
    GROUP_SETUP_VER_RAN=""
fi

if [ "$GROUP_SETUP_VER" = "$GROUP_SETUP_VER_RAN" ]; then
    echo "Flatpak user install (version $GROUP_SETUP_VER) has already run. Exiting..."
    exit 0
fi

# Проверка наличия сети и доступности репозитория Flathub
check_network() {
    local url="https://dl.flathub.org/repo/"
    echo "Checking connection to $url..."

    if ! curl --connect-timeout 10 -s -I "$url" >/dev/null; then
        echo "Error: Failed to connect to $url"
        notify-send "Network error" "Check your internet connection and availability dl.flathub.org." --app-name="Flatpak Manager Service" -u CRITICAL
        exit 1
    fi
}

check_network

notify-send "Flatpak Installation" "Запущена установка Flatpak приложений" --app-name="Flatpak Manager Service" -u NORMAL
echo "Installing user-level Flatpaks..."

fakeroot flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install --user -y flathub com.mattjakeman.ExtensionManager && notify-send "Flatpak Installation" "Installed Extension Manager" --app-name="Flatpak Manager Service" -u NORMAL
flatpak install --user -y flathub org.gnome.NautilusPreviewer && notify-send "Flatpak Installation" "Installed NautilusPreviewer" --app-name="Flatpak Manager Service" -u NORMAL
flatpak install --user -y flathub org.gnome.baobab && notify-send "Flatpak Installation" "Installed baobab" --app-name="Flatpak Manager Service" -u NORMAL
flatpak install --user -y flathub org.gnome.World.PikaBackup && notify-send "Flatpak Installation" "Installed PikaBackup" --app-name="Flatpak Manager Service" -u NORMAL

flatpak install --user -y flathub io.github.dvlv.boxbuddyrs && notify-send "Flatpak Installation" "Installed Boxbuddy" --app-name="Flatpak Manager Service" -u NORMAL
flatpak install --user -y flathub com.github.tchx84.Flatseal && notify-send "Flatpak Installation" "Installed Flatseal" --app-name="Flatpak Manager Service" -u NORMAL
flatpak install --user -y flathub org.telegram.desktop && notify-send "Flatpak Installation" "Installed telegram" --app-name="Flatpak Manager Service" -u NORMAL

notify-send "Flatpak Installation" "Установка завершена" --app-name="Flatpak Manager Service" -u NORMAL
echo "Done installing user-level Flatpaks"

# Запоминаем выполнение вместе с версией скрипта
echo "Writing state file"
echo "$GROUP_SETUP_VER" > "$GROUP_SETUP_VER_FILE"