#!/bin/bash

curl -o /tmp/Anaconda3.sh https://repo.anaconda.com/archive/Anaconda3-5.3.1-Linux-x86_64.sh
bash /tmp/Anaconda3.sh -b -p ${HOME}/.local/anaconda3
