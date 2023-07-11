DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# https://github.com/Aloxaf/silicon

. ${DIR}/dep_cmake.sh
. ${DIR}/dep_gcc.sh

sudo dnf install -y \
  freetype freetype-devel \
  cargo \
  expat.x86_64 expat-devel.x86_64 \
  fontconfig-devel freetype-devel libxml2-devel \
  harfbuzz \
  libxcb-devel

cargo install silicon
sudo dnf clean all
