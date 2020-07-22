DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# https://github.com/Aloxaf/silicon

. ${DIR}/dep_make.sh

sudo dnf install -y \
  cmake \
  freetype freetype-devel \
  cargo \
  gcc-c++ \
  expat expat-devel \
  libxcb-devel

cargo install silicon
