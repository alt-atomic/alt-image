#!/bin/bash

echo "::group:: ===$(basename "$0")==="

TASKS=(
    # alr
    386131
    # systemd (sysusers patch)
    385591
)

for task in "${TASKS[@]}"; do 
    apt-repo add "$task"
done

apt-get update

TASKS_PACKAGES=(
    alr
    systemd
)

if [ ${#TASKS_PACKAGES[@]} -gt 0 ]; then
    apt-get install -y "${TASKS_PACKAGES[@]}"
fi

for task in "${TASKS[@]}"; do 
    apt-repo rm "$task"
done

echo "::endgroup::"
