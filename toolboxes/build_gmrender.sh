
https://github.com/hzeller/gmrender-resurrect
VERSION="0.0.9"


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/dep_automake.sh
. ${DIR}/dep_gcc.sh

sudo dnf install -y \
  glib-devel glibc-devel glib2-devel \
  libupnp-devel \
  gstreamer1-devel gstreamermm-devel \
  gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-ugly-free gstreamer1-plugins-bad-free

SRCDIR=`mktemp -d`
git clone -b v${VERSION} https://github.com/hzeller/gmrender-resurrect.git ${SRCDIR}
cd ${SRCDIR}


./autoconf && ./configure --with-gstreamer --prefix=${HOME}/.local/ && make && make install
