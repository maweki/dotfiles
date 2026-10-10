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
  texlive-pbalance \
  texlive-preprint texlive-makecell \
  texlive-sttools \
  texlive-doclicense \
  texlive-lipsum texlive-blindtext \
  texlive-epigraph \
  texlive-algorithmicx texlive-minted \
  texlive-appendixnumberbeamer \
  texlive-fixmetodonotes texlive-todonotes \
  texlive-acronym \
  texlive-llncs \
  texlive-orcidlink \
  texlive-classicthesis texlive-lni \
  texlive-wrapfig \
  texlive-ifsym texlive-wasysym texlive-wasy \
  texlive-siunitx \
  texlive-mwe \
  texlive-selnolig \
  texlive-noindentafter \
  texlive-stmaryrd \
  texlive-textualicomma \
  texlive-thmtools \
  texlive-ccicons \
  texlive-cleveref texlive-uri \
  texlive-elsarticle \
  texlive-cancel \
  texlive-newtxtt texlive-txfonts \
  texlive-bookmark \
  texlive-lastpage \
  texlive-fontawesome5.noarch \
  texlive-ecltree texlive-eepic \
  hunspell hunspell-en-GB hunspell-en-US hunspell-de \
  texlive-dot2texi dot2tex graphviz \
  texstudio \
  qpdf \
  latexmk
