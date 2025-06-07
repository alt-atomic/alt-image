#!/bin/bash

echo "::group:: ===$(basename "$0")==="

# folder for bootc package
mkdir /sysroot
apt-get update
apt-get -y dist-upgrade
apt-get -y install apt-repo

echo "::endgroup::"
