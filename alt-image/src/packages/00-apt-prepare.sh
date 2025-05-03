#!/bin/bash

echo "::group:: ===$(basename "$0")==="

# folder for bootc package
mkdir /sysroot
apt-get update && apt-get dist-upgrade -y

echo "::endgroup::"