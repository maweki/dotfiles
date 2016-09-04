#!/bin/sh

cd /tmp
curl https://raw.githubusercontent.com/maweki/dotfiles/master/common/.ssh/authorized_keys > ak
mkdir ~/.ssh
cat ak >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
