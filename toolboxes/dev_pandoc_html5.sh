DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# build environment for html5 pandoc building

sudo dnf install -y \
  pandoc \
  java-11-openjdk-headless
sudo dnf clean all
sudo pip3 install html5validator
