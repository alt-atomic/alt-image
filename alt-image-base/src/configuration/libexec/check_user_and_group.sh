#!/bin/bash
# Причина этого скрипта в том что ALT не соблюдает systemd-tmpfiles.
# Скрипт синхронизирует только каталоги из ostree-коммита избегая замену файлов
#

set -euo pipefail

# Получаем первую ревизию из вывода команды ostree admin status.
REVISION=$(ostree admin status | awk '/^\* default/ {print $3; exit}')

if [[ -z "$REVISION" ]]; then
    echo "Не удалось получить ревизию ostree."
    exit 1
fi

echo "Найдена ревизия: $REVISION"

# Формируем путь к каталогу /var в развёрнутой ревизии ostree.
OSTREE_VAR="/ostree/deploy/default/deploy/${REVISION}/var"
# Проверяем, существует ли указанный каталог. Если нет – выводим сообщение и выходим.
if [[ ! -d "$OSTREE_VAR" ]]; then
    echo "Каталог $OSTREE_VAR не найден. Проверьте корректность развёртки ostree."
    exit 1
fi

echo "Синхронизация содержимого из $OSTREE_VAR в /var"

# Выполняем синхронизацию:
#   - -a                : архивный режим (рекурсивное копирование, сохранение прав, владельцев, временных меток и т.д.)
#   - --ignore-existing: не заменять уже существующие файлы/каталоги
#   - --include '*/'    : включить все каталоги (и их подкаталоги)
#   - --exclude '*'     : исключить все файлы (будут копироваться только каталоги)
#rsync -av --ignore-existing --include '*/' --exclude '*' "${OSTREE_VAR}/" /var/
rsync -av \
    --exclude='home/' \
    --exclude='root/' \
    --exclude='tmp/' \
    --include='*/' \
    --exclude='*' \
    "${OSTREE_VAR}/" /var/

echo "Синхронизация завершена."