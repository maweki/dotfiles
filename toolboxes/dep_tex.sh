DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/dep_make.sh

sudo dnf install -y \
  texlive \
  texlive-biblatex \
  texlive-pgfplots \
  texlive-esvect \
  texlive-collection-langenglish \
  texlive-collection-langgerman \
  texlive-hyphen-english \
  texlive-hyphen-german \
  texlive-lipsum \
  texlive-algorithmicx \
  texlive-fixmetodonotes \
  texlive-acronym \
  texlive-classicthesis \
  texlive-wrapfig \
  texlive-ifsym \
  texlive-noindentafter \
  hunspell hunspell-en-GB hunspell-en-US hunspell-de
