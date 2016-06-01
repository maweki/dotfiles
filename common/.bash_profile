# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

if [ -d $HOME/.cabal/bin ] ; then
	PATH=$HOME/.cabal/bin:$PATH
fi

PATH=$HOME/.local/bin:$PATH

export PATH
