#!/bin/bash

echo "::group:: ===$(basename "$0")==="

TASKS=(
  # atomic-actions
  386243
  # apm
  386155
  # alr
  386131
)

for task in "${TASKS[@]}"; do
  apt-repo test -y "$task"
done

echo "::endgroup::"
