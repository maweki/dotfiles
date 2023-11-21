set -eu
pushd `mktemp -d`
curl http://ftp.gnu.org/gnu/stow/stow-latest.tar.gz -o src.tar.gz
tar -xzf src.tar.gz
cd stow-*
./configure
make
cd bin
DIR=$(dirs -l +1)
cp stow ${DIR}
popd
