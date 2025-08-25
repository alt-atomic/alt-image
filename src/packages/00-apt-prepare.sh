#!/bin/bash

echo "::group:: ===$(basename "$0")==="

mkdir -p /usr/share/rpm
rsync -aA /var/lib/rpm/ /usr/share/rpm/
rm -rf /var/lib/rpm && ln -s ../../usr/share/rpm /var/lib/rpm

rm -rf /etc/apt/sources.list.d

mkdir -p /usr/share/apt
rsync -aA /etc/apt/ /usr/share/apt/
rm -rf /etc/apt && ln -s ../../usr/share/apt /etc/apt

arch=$(uname -m)
repo_date="$REPO_YEAR/$REPO_MONTH/$REPO_DAY"
case "$arch" in
    x86_64)
        cat << EOF > /etc/apt/sources.list
# Local package resource list for APT goes here.
rpm [alt] https://ftp.altlinux.org/pub/distributions/archive sisyphus/date/$repo_date/noarch classic
rpm [alt] https://ftp.altlinux.org/pub/distributions/archive sisyphus/date/$repo_date/x86_64 classic
rpm [alt] https://ftp.altlinux.org/pub/distributions/archive sisyphus/date/$repo_date/x86_64-i586 classic
EOF
        ;;
    aarch64)
        cat << EOF > /etc/apt/sources.list
# Local package resource list for APT goes here.
rpm [alt] https://ftp.altlinux.org/pub/distributions/archive sisyphus/date/$repo_date/noarch classic
rpm [alt] https://ftp.altlinux.org/pub/distributions/archive sisyphus/date/$repo_date/aarch64 classic
EOF
        ;;
    *)
        echo "Unsupported arch: $ARCH" >&2
        exit 1
        ;;
esac

# folder for bootc package
mkdir /sysroot
apt-get update
apt-get -y dist-upgrade
apt-get -y install apt-repo

echo "::endgroup::"
