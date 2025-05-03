#!/usr/bin/bash


echo "::group:: ===$(basename "$0")==="

set -xeou pipefail

cd /tmp
mkdir -p /home/linuxbrew/

# Переменная которая говорит что мы внутри контейнера
touch /.dockerenv

# Brew Install
curl --retry 3 -Lo /tmp/brew-install https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
chmod +x /tmp/brew-install
/tmp/brew-install
tar --zstd -cvf /usr/share/homebrew.tar.zst /home/linuxbrew/.linuxbrew
rm /.dockerenv
/usr/bin/chown -R 1000:1000 /home/linuxbrew

echo "::endgroup::"