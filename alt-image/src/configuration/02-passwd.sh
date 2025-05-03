#!/bin/bash

echo "::group:: ===$(basename "$0")==="

# Задаём пароль для root
echo "root:root" | chpasswd

echo "::endgroup::"