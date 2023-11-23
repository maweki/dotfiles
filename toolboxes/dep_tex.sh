DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/dep_make.sh

sudo dnf install -y \
  texlive \
  texlive-biblatex texlive-biblatex-lni\
  texlive-pgfplots \
  texlive-amscdx \
  texlive-esvect \
  texlive-pict2e texlive-xypic \
  texlive-multirow \
  texlive-collection-langenglish texlive-hyphen-english \
  texlive-collection-langgerman texlive-hyphen-german \
  texlive-lipsum texlive-blindtext \
  texlive-algorithmicx texlive-minted \
  texlive-appendixnumberbeamer \
  texlive-fixmetodonotes \
  texlive-acronym \
  texlive-classicthesis texlive-lni \
  texlive-wrapfig \
  texlive-ifsym texlive-wasysym texlive-wasy \
  texlive-siunitx \
  texlive-mwe \
  texlive-noindentafter \
  texlive-stmaryrd \
  texlive-textualicomma \
  texlive-thmtools \
  texlive-ccicons \
  texlive-cleveref texlive-uri \
  texlive-cancel \
  texlive-newtxtt texlive-txfonts \
  texlive-bookmark \
  texlive-fontawesome5.noarch \
  texlive-ecltree texlive-eepic \
  hunspell hunspell-en-GB hunspell-en-US hunspell-de \
  texlive-dot2texi dot2tex graphviz \
  texstudio
