# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment and startup programs

if [ -d $HOME/.cabal/bin ] ; then
	PATH=$HOME/.cabal/bin:$PATH
fi

export PATH=$HOME/.local/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HOME}/.local/lib


# TZ / LANG
export TZ="Europe/Berlin"

# colorful terminal with results color
PS1='\[`[ $? = 0 ] && X=2 || X=1; tput setaf $X`\]\u@\h\[`tput sgr0`\]:$PWD\n\$ '

if which git &> /dev/null ; then
		# adding git completion and info
		[ -s /usr/share/git-core/contrib/completion/git-prompt.sh ] && source /usr/share/git-core/contrib/completion/git-prompt.sh
		[ -s /usr/share/doc/git-core-doc/contrib/completion/git-prompt.sh ] && source /usr/share/doc/git-core-doc/contrib/completion/git-prompt.sh
		[ -s /usr/share/doc/git-core-doc/contrib/completion/git-completion.bash ] && source /usr/share/doc/git-core-doc/contrib/completion/git-completion.bash
		[ -s /etc/bash_completion.d/git ] && source /etc/bash_completion.d/git
		[ -s /etc/bash_completion.d/git-flow-completion.bash ] && source /etc/bash_completion.d/git-flow-completion.bash

		export GIT_PS1_SHOWDIRTYSTATE=1

		if which __git_ps1 &> /dev/null ; then
				PS1='\[`[ $? = 0 ] && X=2 || X=1; tput setaf $X`\]\u@\h\[`tput sgr0`\]:$PWD$(__git_ps1)\n\$ '
		fi
		if which __git_complete &> /dev/null ; then
				__git_complete g __git_main
		fi
fi

export EDITOR=nano

if which python &> /dev/null ; then
		alias pp='python -mjson.tool'
		alias sum='python -c "import sys; print sum(int(l) for l in sys.stdin)"'
		if which pip &> /dev/null ; then
			alias pipiu='pip install --user'
		fi
fi

if which python3 &> /dev/null ; then
	alias httpserver='python3 -m http.server'
fi

if [ -d ${HOME}/.local/lib/python3.*/site-packages/dg ] ; then
		alias dg="python3 -m dg"
fi

if [ -n "$UNDER_JHBUILD" ]; then
    PS1="[jhbuild] $PS1"
fi


alias remove_trailing_spaces="sed --in-place 's/[[:space:]]\+$//'"
alias e="echo"
alias g="git"

export NVM_DIR="${HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend
export HISTSIZE=5000

# color everything
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias lsd='ls -tl'
alias lss='ls -Sl'
alias xzegrep='xzegrep --color=auto'
alias xzfgrep='xzfgrep --color=auto'
alias xzgrep='xzgrep --color=auto'
alias zegrep='zegrep --color=auto'
alias zfgrep='zfgrep --color=auto'
alias zgrep='zgrep --color=auto'


# bash-completion for sudo
complete -cf sudo
