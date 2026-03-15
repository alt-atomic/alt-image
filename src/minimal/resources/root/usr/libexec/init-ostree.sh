#!/bin/bash
set -e

echo "Проверка ostree commit"

# Проверка `ostree refs`
if ostree --repo=/sysroot/ostree/repo refs | grep -q .; then
  echo "Репозиторий найден."
else
  echo "Создание коммита, пожалуйста ожидайте."

  ## Инициализация OSTree репозитория
  mkdir -p /sysroot/ostree/repo
  ostree --repo=/sysroot/ostree/repo init --mode=archive

  ## Подготовка временной директории
  mkdir -p /tmp/rootfscopy

  rsync -aA \
    --exclude=/home \
    --exclude=/dev \
    --exclude=/proc \
    --exclude=/sys \
    --exclude=/run \
    --exclude=/boot \
    --exclude=/tmp \
    --exclude=/var \
    --exclude=/output \
    / /tmp/rootfscopy/

  mkdir -p /tmp/rootfscopy/var/tmp

  ostree --repo=/sysroot/ostree/repo commit \
    --branch=alt/atomic \
    --subject "Initial ALT Atomic Commit" \
    --tree=dir=/tmp/rootfscopy

  ## Очистка временной директории
  rm -rf /tmp/rootfscopy

  echo "Initial OSTree commit created."
fi
