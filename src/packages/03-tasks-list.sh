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

apt-repo test -y "${TASKS[@]}"

echo "::endgroup::"
