#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

sudo dnf install -y ~/sync/atom.x86_64.rpm
sudo dnf install -y gdk-pixbuf2 gtk3 libX11-xcb libxkbfile alsa-lib

bash $DIR/dep_haskell.sh
sudo dnf install libicu-devel ncurses-devel
source ~/.bashrc
cd /tmp
git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules
cd haskell-ide-engine
stack ./install.hs hie

cd ${DIR}
cd ..
apm install --packages-file apm-packages
sudo dnf clean all
