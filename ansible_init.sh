#!/bin/sh

cd /tmp
curl https://raw.githubusercontent.com/maweki/dotfiles/master/common/.ssh/authorized_keys > ak
mkdir ~/.ssh
cat ak >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

if which apt-get &> /dev/null ; then
	sudo apt-get update
	sudo apt-get install -y python3 python ssh-client
fi
if which dnf &> /dev/null ; then
	sudo dnf install -y openssh-clients
fi
