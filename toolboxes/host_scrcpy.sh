#!/bin/bash

#https://github.com/Genymobile/scrcpy/blob/master/BUILD.md
VERSION="1.17"

# enable RPM fusion free
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

# client build dependencies
sudo dnf install -y SDL2-devel ffms2-devel meson gcc make

# server build dependencies
sudo dnf install -y java-devel

# android tools and graphics driver
sudo dnf install -y android-tools mesa-dri-drivers

SRCDIR=`mktemp -d`
git clone -b v${VERSION} https://github.com/Genymobile/scrcpy ${SRCDIR}
cd ${SRCDIR}

source ~/.bashrc
meson x --buildtype release --strip -Db_lto=true
ninja -Cx
sudo ninja -Cx install
cd /tmp
rm -rf ${SRCDIR}
sudo dnf clean all
