DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/dep_haskell.sh
sudo dnf install indent

sudo pip install -U platformio
sudo dnf clean all
