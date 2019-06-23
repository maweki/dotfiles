#!/bin/bash
# check for everything I regularily use

#print failure
# fail ( name )
function fail {
  echo $' \e[31m(\u2717)\e[39m '"$1"
}

#print success
# succ ( name )
function succ {
  echo $' \e[32m(\u2713)\e[39m '"$1"
}

# check whether a file exists
# check_f( file, name )
function check_f {
  if [ -f "$1" ] ; then
    succ "$2"
  else
    fail "$2"
  fi
}

# check whether a directory exists
# check_f( directory, name )
function check_d {
  if [ -d "$1" ] ; then
    succ "$2"
  else
    fail "$2"
  fi
}

# check whether a command executes successfully
# check_f( command, name )
function check_c {
  if $1 &> /dev/null ; then
    succ "$2"
  else
    fail "$2"
  fi
}

echo "System:"
check_c "stow --version" "stow"
check_c "pv --version" "pv"
check_c "htop --version" "htop"
check_c "iotop --version" "iotop"
check_c "tmux -V" "tmux"
check_c "nethogs -V" "nethogs"
check_c "git --version" "git"
check_c "which git-flow" "git flow"
check_c "nano --version" "nano"
check_c "vim --version" "vim"
check_c "pwgen" "pwgen"
check_c "trickle true" "trickle"
check_c "unzip" "unzip"
check_c "which scp" "scp"
check_c "rsync --version" "rsync"
check_c "curl --version" "curl"
check_c "wget --version" "wget"
check_c "pass --version" "pass"
check_c "hstr --version" "hstr" # https://github.com/dvorka/hstr
check_c "googler --version" "googler" # https://github.com/jarun/googler
check_c "ddgr --version" "ddgr" # https://github.com/jarun/ddgr

echo "Python:"
check_c "python2 --version" "python2"
check_c "python3 --version" "python3"
check_c "pip2 --version" "pip2"
check_c "pip3 --version" "pip3"
check_c "wheel -h" "wheel"
check_c "virtualenv --version" "virtualenv"
check_c "nosetests --version" "nosetests"
check_c "coverage --version" "coverage"
check_c "pylint --version" "PyLint"
check_c "joe --version" "joe (gitignore files)"
check_c "howdoi --version" "howdoi"
check_c "twitter --help" "twitter"
check_c "which hn" "haxor-news (hn)"
check_c "rtv --version" "Reddit Viewer (rtv)"
check_d ${HOME}/.local/lib/python3.*/site-packages/dg "Dogelang (dg)"

echo "JavaScript:"
check_c "node --version" "node"
check_c "npm --version" "npm"
check_f "${HOME}/.nvm/nvm.sh" "nvm (Node Version Manager)"
check_c "grunt --version" "grunt"
check_c "bower --version" "bower"
check_c "phantomjs --version" "PhantomJS"
check_c "jshint --version" "jshint"
check_c "gjs --help" "gjs"
check_c "atom --version" "atom"
check_c "apm --version" "apm"

if apm --version &> /dev/null; then
  echo "APM packages:"
  APMINST=`apm list --installed --bare | grep -o "^[^@]*"`
  while read package; do
    # I am too dumb to correctly escape this one to use check_c
    if echo "${APMINST}" | grep "^${package}$" &> /dev/null; then
      succ "$package" ;  else
      fail "$package" ;  fi
  done < apm-packages
fi

echo "Java:"
check_c "java -version" "java"
check_c "javac -version" "javac"

echo "Haskell:"
check_c "ghc --version" "ghc"
check_c "ghci --version" "ghci"
check_c "cabal --version" "cabal"
check_c "hlint --version" "HLint"
check_c "shellcheck -V" "ShellCheck"
check_c "stack --version" "stack"

echo "Deductive and DB:"
check_c "swipl --version" "swi-Prolog"
check_c "datalog -v" "datalog"
check_c "souffle" "souffle"
check_c "sqlite3 --version" "sqlite3"

echo "ImageMagick:"
check_c "mogrify --version" "mogrify"
check_c "convert --version" "convert"

echo "LaTeX:"
check_c "pdflatex --version" "pdflatex"
check_c "bibtex --version" "bibtex"
check_c "latex --version" "latex"
check_c "latexmk --version" "latexmk"

echo "GUI:"
check_c "gitg --version" "gitg"
check_c "git gui --version" "git gui"
check_c "gimp --version" "GIMP"
check_c "inkscape --version" "inkscape"
check_c "atom --version" "Atom"
check_c "which xpdf" "xpdf"
check_c "which filezilla" "filezilla"
check_c "vlc --version" "VLC"
check_c "cvlc --version" "cVLC"

echo "Other:"
check_c "dot -V" "dot (GraphViz)"
