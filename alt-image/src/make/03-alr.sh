#!/bin/bash

set -euo pipefail

echo "::group:: ===$(basename "$0")==="

# Создаем временную директорию
TMP_DIR=$(mktemp -d)
echo "Используем временную директорию: $TMP_DIR"
cd "$TMP_DIR"

# URL rpm-пакета
RPM_URL="https://code.aides.space/aides-infra/ALR/releases/download/v0.0.10-pre/alr-bin+alr-default-0.0.10-pre-alt1.x86_64.rpm"
RPM_FILE=$(basename "$RPM_URL")

# Скачиваем rpm-пакет
echo "Скачиваем $RPM_FILE..."
wget -O "$RPM_FILE" "$RPM_URL"

# Устанавливаем rpm-пакет с помощью apt-get
echo "Устанавливаем $RPM_FILE с помощью apt-get..."
apt-get install -y ./"$RPM_FILE"

# Возвращаемся в исходную директорию и очищаем временные файлы
cd - > /dev/null
rm -rf "$TMP_DIR"

echo "::endgroup::"