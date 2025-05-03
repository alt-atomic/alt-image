#!/bin/bash

echo "::group:: ===$(basename "$0")==="

rm -rf /var/root/.cargo
rm -rf /var/root/.rustup
rm -rf /var/root/.cache
rm -rf /var/root/.profile
rm -rf /var/root/go
rm -rf /boot/*
truncate -s 0 /var/log/lastlog

echo "::endgroup::"