#!/bin/sh

cd /tmp
curl https://raw.githubusercontent.com/maweki/dotfiles/master/common/.ssh/authorized_keys > ak
mkdir ~/.ssh
cat ak >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

if which apt-get &> /dev/null ; then
	apt-get update
	apt-get install -y python ssh-client
fi
if which dnf &> /dev/null ; then
	dnf install -y openssh-clients
fi
