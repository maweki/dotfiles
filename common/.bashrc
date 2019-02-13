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
#export TZ="Europe/Berlin"

# colorful terminal with results color
PS1='\[`[ $? = 0 ] && X=2 || X=1; tput setaf $X`\]\u@\h\[`tput sgr0`\]:$PWD\n\$ '

# prevent ctrl+s from keeping on freezing because I can never remember ctrl+q
stty ixany

# start tmux and go from there
#[[ -z $TMUX ]] && which tmux &> /dev/null && (exec tmux) 

if which git &> /dev/null ; then
		# adding git completion and info
		[ -s /usr/share/git-core/contrib/completion/git-prompt.sh ] && source /usr/share/git-core/contrib/completion/git-prompt.sh
		[ -s /usr/share/doc/git-core-doc/contrib/completion/git-completion.bash ] && source /usr/share/doc/git-core-doc/contrib/completion/git-completion.bash
		[ -s /etc/bash_completion.d/git-prompt ] && source /etc/bash_completion.d/git-prompt
		[ -s /usr/share/doc/git-core-doc/contrib/completion/git-prompt.sh ] && source /usr/share/doc/git-core-doc/contrib/completion/git-prompt.sh
		[ -s /etc/bash_completion.d/git ] && source /etc/bash_completion.d/git
		[ -s /etc/bash_completion.d/git-flow-completion.bash ] && source /etc/bash_completion.d/git-flow-completion.bash

		export GIT_PS1_SHOWDIRTYSTATE=1

		if __git_ps1 &> /dev/null ; then
				PS1='\[`[ $? = 0 ] && X=2 || X=1; tput setaf $X`\]\u@\h\[`tput sgr0`\]:$PWD$(__git_ps1)\n\$ '
		fi

		if which __git_wrap__git_main &> /dev/null ; then
				complete -o bashdefault -o default -o nospace -F __git_wrap__git_main g
		fi
fi

export EDITOR=nano

if which python3 &> /dev/null ; then
	alias pp='python3 -mjson.tool'
	alias sum='python3 -c "import sys; print(sum(int(l) for l in sys.stdin))"'
	alias sumf='python3 -c "import sys; print(sum(float(l) for l in sys.stdin))"'
	alias httpserver='python3 -m http.server'
fi

if which stack &> /dev/null ; then
	eval "$(stack --bash-completion-script stack)"
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

alias issh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
complete -F _ssh issh

export NVM_DIR="${HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend
export HISTSIZE=5000
HISTCONTROL=ignoreboth
HISTIGNORE='ls:bg:fg:history'
PROMPT_COMMAND='history -a'

# color everything
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias lsd='ls -tl'
alias lss='ls -Sl'
alias ..='cd ..'
alias xzegrep='xzegrep --color=auto'
alias xzfgrep='xzfgrep --color=auto'
alias xzgrep='xzgrep --color=auto'
alias zegrep='zegrep --color=auto'
alias zfgrep='zfgrep --color=auto'
alias zgrep='zgrep --color=auto'

[ -s ~/.plog.sh ] && source ~/.plog.sh

# bash-completion for sudo
complete -cf sudo


# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$(CONDA_REPORT_ERRORS=false '~/.local/anaconda3/bin/conda' shell.bash hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    \eval "$__conda_setup"
else
    if [ -f "~/.local/anaconda3/etc/profile.d/conda.sh" ]; then
        . "~/.local/anaconda3/etc/profile.d/conda.sh"
        CONDA_CHANGEPS1=false conda activate base
    else
        \export PATH="~/.local/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda init <<<
