#!/bin/bash

#https://www.zettlr.com/download/rpm
VERSION="1.8.7"

DLDIR=`mktemp -d`
wget -o ${DLDIR}/Zettlr.rpm https://github.com/Zettlr/Zettlr/releases/download/v${VERSION}/Zettlr-${VERSION}-x86_64.rpm

# zettlr itself
sudo dnf install -y \
  ${DLDIR}/Zettlr.rpm \
  libX11-xcb libdrm mesa-libgbm alsa-lib

sudo dnf clean all
