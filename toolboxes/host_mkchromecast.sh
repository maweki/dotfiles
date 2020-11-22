DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# github.com/muammar/mkchromecast

. ${DIR}/dep_make.sh
. ${DIR}/dep_gcc.sh

sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install -y \
  python3-cairo-devel python3-cairo \
  gobject-introspection-devel cairo-gobject-devel \
  ffmpeg ffmpeg-devel \
  pulseaudio-utils lame

SRCDIR=`mktemp -d`

git clone https://github.com/muammar/mkchromecast.git ${SRCDIR}
cd ${SRCDIR}

sudo pip install -r requirements.txt
sudo pip install .

cd
sudo dnf clean all
rm -rf ${SRCDIR}
