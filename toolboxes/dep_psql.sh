set +e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

VERSION="13.1"

. ${DIR}/dep_make.sh
. ${DIR}/dep_gcc.sh

sudo dnf install -y \
  readline-devel zlib-devel

TMPDIR=`mktemp -d`

cd ${TMPDIR}
wget https://ftp.postgresql.org/pub/source/v${VERSION}/postgresql-${VERSION}.tar.gz
gunzip postgresql-${VERSION}.tar.gz
tar xf postgresql-${VERSION}.tar
cd postgresql-${VERSION}
./configure --prefix=/usr/local
make
sudo make install
rm -rf ${TMPDIR}

echo "use initdb to initialize a database"
echo "use pg_ctl -D /dbpath start to start the server"
echo "use createdb to create a database"
