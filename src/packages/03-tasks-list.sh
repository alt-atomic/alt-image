#!/bin/bash

echo "::group:: ===$(basename "$0")==="

TASKS=(
    386243
    386155
    386131
)

for task in "${TASKS[@]}"; do 
    apt-repo add task "$task"
done

apt-get update

TASKS_PACKAGES=(
    atomic-actions
    apm
    alr
)

if [ ${#TASKS_PACKAGES[@]} -gt 0 ]; then
    apt-get install -y "${TASKS_PACKAGES[@]}"
fi

echo "::endgroup::"
