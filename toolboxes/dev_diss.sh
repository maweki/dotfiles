DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# build environment for dissertation

. ${DIR}/dep_tex.sh

sudo dnf install -y \
  pandoc \
  entr
sudo dnf clean all
