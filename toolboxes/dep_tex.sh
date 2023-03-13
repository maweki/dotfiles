DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/dep_make.sh

sudo dnf install -y \
  texlive \
  texlive-biblatex texlive-biblatex-lni\
  texlive-pgfplots \
  texlive-esvect \
  texlive-multirow \
  texlive-collection-langenglish texlive-hyphen-english \
  texlive-collection-langgerman texlive-hyphen-german \
  texlive-lipsum \
  texlive-algorithmicx texlive-minted \
  texlive-fixmetodonotes \
  texlive-acronym \
  texlive-classicthesis texlive-lni \
  texlive-wrapfig \
  texlive-ifsym \
  texlive-noindentafter \
  texlive-stmaryrd \
  texlive-textualicomma \
  texlive-thmtools \
  texlive-ccicons \
  texlive-cleveref \
  texlive-cancel \
  texlive-newtxtt \
  hunspell hunspell-en-GB hunspell-en-US hunspell-de \
  texlive-dot2texi dot2tex graphviz
