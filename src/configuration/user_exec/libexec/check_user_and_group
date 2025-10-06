#!/bin/bash
# Причина этого скрипта в том что ALT не поддерживает systemd-sysusers.
# Скрипт объединяет учётные записи и группы из базовых файлов (/usr/etc/passwd и /usr/etc/group)
# с локальными (/etc/passwd и /etc/group)

set -e

echo "=== Начало синхронизации пользователей и групп ==="

###############################################################################
# Часть 1. Добавление пользователей в дополнительные группы
###############################################################################
groups_to_add=(docker lxd cuse fuse libvirt adm wheel uucp cdrom cdwriter audio users video netadmin scanner xgrp camera render usershares)

# Получаем всех пользователей с UID ≥ 1000, исключая "nobody"
userarray=($(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd))
if [[ ${#userarray[@]} -eq 0 ]]; then
    echo "Нет пользователей с UID ≥ 1000."
    exit 0
fi

for user in "${userarray[@]}"; do
    echo "Обрабатываем пользователя $user..."
    for grp in "${groups_to_add[@]}"; do
        if ! getent group "$grp" >/dev/null 2>&1; then
            echo "Группа $grp не существует, пропускаем для $user."
            continue
        fi
        if id -nG "$user" | tr ' ' '\n' | grep -qx "$grp"; then
            echo "Пользователь $user уже состоит в группе $grp, пропускаем."
        else
            echo "Добавляем пользователя $user в группу $grp..."
            usermod -aG "$grp" "$user"
        fi
    done
done

###############################################################################
# Часть 2. Объединение файла /etc/passwd
###############################################################################
BASE_PASSWD="/usr/etc/passwd"
LOCAL_PASSWD="/etc/passwd"
MERGED_PASSWD="/tmp/merged-passwd.$$"

declare -A base_passwd_arr   # base_passwd_arr[username]=строка из базового файла
declare -A local_passwd_arr  # local_passwd_arr[username]=строка из локального файла

# Чтение базового файла (системные аккаунты, UID < 1000)
while IFS=':' read -r username passwd uid gid gecos home shell; do
    username=$(echo "$username" | xargs)
    [[ -z "$username" ]] && continue
    base_passwd_arr["$username"]="${username}:${passwd}:${uid}:${gid}:${gecos}:${home}:${shell}"
done < "$BASE_PASSWD"

# Чтение локального файла
while IFS=':' read -r username passwd uid gid gecos home shell; do
    username=$(echo "$username" | xargs)
    [[ -z "$username" ]] && continue
    local_passwd_arr["$username"]="${username}:${passwd}:${uid}:${gid}:${gecos}:${home}:${shell}"
done < "$LOCAL_PASSWD"

# Создаем временный файл для объединенного списка
rm -f "$MERGED_PASSWD"
: > "$MERGED_PASSWD" || { echo "Ошибка: не удалось создать $MERGED_PASSWD"; exit 1; }

# Добавляем локальные записи для пользователей с UID ≥ 1000
for username in "${!local_passwd_arr[@]}"; do
    IFS=':' read -r _ _ local_uid _ _ _ _ <<< "${local_passwd_arr[$username]}"
    if (( local_uid >= 1000 )); then
        echo "${local_passwd_arr[$username]}" >> "$MERGED_PASSWD"
    fi
done

# Добавляем системные записи (UID < 1000) из базового файла
for username in "${!base_passwd_arr[@]}"; do
    IFS=':' read -r _ _ base_uid _ _ _ _ <<< "${base_passwd_arr[$username]}"
    if (( base_uid < 1000 )); then
        echo "${base_passwd_arr[$username]}" >> "$MERGED_PASSWD"
    fi
done

sort "$MERGED_PASSWD" -o "$MERGED_PASSWD"
echo "Объединение /etc/passwd завершено. Результат: $MERGED_PASSWD"

cp "$LOCAL_PASSWD" "${LOCAL_PASSWD}.bak"
mv "$MERGED_PASSWD" "$LOCAL_PASSWD"
echo "/etc/passwd обновлён."

###############################################################################
# Часть 3. Объединение файла /etc/group с корректировкой GID и объединением списков членов
###############################################################################
BASE_GROUP="/usr/etc/group"
LOCAL_GROUP="/etc/group"
MERGED_GROUP="/tmp/merged-group.$$"

declare -A base_group_arr  # base_group_arr[group]=строка из базового файла
declare -A base_gid_arr    # base_gid_arr[group]=GID из базового файла
declare -A local_group_arr # local_group_arr[group]=строка из локального файла

# Чтение базового файла групп
while IFS=':' read -r grp pwd gid members; do
    grp=$(echo "$grp" | xargs)
    [[ -z "$grp" ]] && continue
    gid_clean=$(echo "$gid" | tr -d '[:space:]')
    base_group_arr["$grp"]="${grp}:${pwd}:${gid_clean}:${members}"
    base_gid_arr["$grp"]="$gid_clean"
done < "$BASE_GROUP"

# Чтение локального файла групп
while IFS=':' read -r grp pwd gid members; do
    grp=$(echo "$grp" | xargs)
    [[ -z "$grp" ]] && continue
    gid_clean=$(echo "$gid" | tr -d '[:space:]')
    local_group_arr["$grp"]="${grp}:${pwd}:${gid_clean}:${members}"
done < "$LOCAL_GROUP"

# Сбор основных групп, используемых в /etc/passwd
declare -A primary_groups  # primary_groups[group]=1
while IFS=':' read -r username _ _ gid _; do
    gid_clean=$(echo "$gid" | tr -d '[:space:]')
    grp_name=$(getent group "$gid_clean" | cut -d: -f1)
    if [[ -n "$grp_name" ]]; then
        primary_groups["$grp_name"]=1
    fi
done < /etc/passwd

# Создаем временный файл для объединенного списка групп
rm -f "$MERGED_GROUP"
: > "$MERGED_GROUP" || { echo "Ошибка: не удалось создать $MERGED_GROUP"; exit 1; }

# Обработка групп, присутствующих в базовом файле
for grp in "${!base_group_arr[@]}"; do
    base_gid_val="${base_gid_arr[$grp]}"
    if [[ -n "${local_group_arr[$grp]:-}" ]]; then
        IFS=':' read -r lgrp lpwd lgid lmembers <<< "${local_group_arr[$grp]}"
        lgid=$(echo "$lgid" | tr -d '[:space:]')
        if [[ "$lgid" != "$base_gid_val" ]]; then
            lgid="$base_gid_val"
        fi
        IFS=':' read -r _ _ _ bmembers <<< "${base_group_arr[$grp]}"
        # Объединяем списки членов из локальной и базовой записей без дубликатов
        merged_members=$(echo "$lmembers,$bmembers" | tr ',' '\n' | awk 'NF' | sort -u | paste -sd, -)
        echo "${grp}:${lpwd}:${lgid}:${merged_members}" >> "$MERGED_GROUP"
    else
        echo "${base_group_arr[$grp]}" >> "$MERGED_GROUP"
    fi
done

# Обработка локальных групп, отсутствующих в базовом файле
for grp in "${!local_group_arr[@]}"; do
    if [[ -z "${base_group_arr[$grp]:-}" ]]; then
        if [[ -n "${primary_groups[$grp]:-}" ]]; then
            echo "${local_group_arr[$grp]}" >> "$MERGED_GROUP"
        fi
    fi
done

sort "$MERGED_GROUP" -o "${MERGED_GROUP}.tmp" && mv "${MERGED_GROUP}.tmp" "$MERGED_GROUP"
echo "Объединение /etc/group завершено. Результат:"

cp "$LOCAL_GROUP" "${LOCAL_GROUP}.bak"
cat "$MERGED_GROUP" > "$LOCAL_GROUP"
echo "/etc/group обновлён."

echo "=== Синхронизация пользователей и групп завершена ==="