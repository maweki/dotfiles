DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

curl -sSL https://get.haskellstack.org/ | sh
cd ~
/usr/local/bin/stack setup
