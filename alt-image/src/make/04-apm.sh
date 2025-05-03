#!/bin/bash

set -euo pipefail

echo "::group:: ===$(basename "$0")==="

curl -fsSL https://raw.githubusercontent.com/alt-atomic/apm/main/data/install.sh | sudo bash

echo "::endgroup::"