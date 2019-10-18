#!/bin/bash

curl -o /tmp/Anaconda3.sh https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh
bash /tmp/Anaconda3.sh -b -p ${HOME}/.local/anaconda3
rm /tmp/Anaconda3.sh
