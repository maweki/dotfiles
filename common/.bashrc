# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment and startup programs

if [ -d $HOME/.cabal/bin ] ; then
	PATH=$HOME/.cabal/bin:$PATH
fi

if [ -d $HOME/.cargo/bin ] ; then
	PATH=$HOME/.cargo/bin:$PATH
fi

if [ -d ${HOME}/.local/android/sdk ] ; then
		export ANDROID_HOME=${HOME}/.local/android/sdk
		export PATH="${PATH}:${ANDROID_HOME}tools/:${ANDROID_HOME}platform-tools/"
fi

export PATH=$HOME/.local/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HOME}/.local/lib


# TZ / LANG
#export TZ="Europe/Berlin"

# colorful terminal with results color
PS1='\[`[ $? = 0 ] && X=2 || X=1; tput setaf $X`\]\u@\h\[`tput sgr0`\]:$PWD$(__screen_info)\n\$ '

# prevent ctrl+s from keeping on freezing because I can never remember ctrl+q
stty ixany

# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
set -o noclobber

# Update window size after every command
shopt -s checkwinsize

# Enable the future of globbing
shopt -s globstar

# Turn on recursive globbing (enables ** to recurse all directories)
shopt -s globstar 2> /dev/null

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# start tmux and go from there
#[[ -z $TMUX ]] && which tmux &> /dev/null && (exec tmux)

if which xdg-open &> /dev/null ; then
	alias x='xdg-open'
fi

if which screen &> /dev/null ; then
__screen_info () {
if echo -n "${TERM}" | grep "screen\\." &> /dev/null; then
    echo -n ' {C-a '
    tput bold; echo -n 'd'; tput sgr0; echo -n 'etach'
		tput sgr0; echo -n " / "
    echo -n 'splitR'; tput setaf 2; echo -n '-'; tput setaf 1; echo -n '|'; tput setaf 2; echo -n ' S'; tput setaf 1; echo -n '|'
		tput sgr0; echo -n " / "
		echo -n 'removeR X'
		tput sgr0; echo -n " / "
		tput bold; echo -n 'c'; tput sgr0; echo -n 'reateW'
		tput sgr0; echo -n " / "
		tput bold; echo -n 'k'; tput sgr0; echo -n 'illW'
		tput sgr0; echo -n " / "
		echo -n 'Wlist "'
		tput sgr0; echo -n " / "
		echo -n 'copy esc'
		tput sgr0; echo -n " / "
		echo -n 'terminate \'
    echo -n '}'
else
    __detached=$(top -b -n 1 | grep ' screen' &> /dev/null && echo -n `screen -ls | grep Detached`)
		[ -z "${__detached}" ] || (echo -n " ["; echo -n "${__detached}"; echo -n "]")
fi
}
else
__screen_info () {
	return
}
fi

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
				PS1='\[`[ $? = 0 ] && X=2 || X=1; tput setaf $X`\]\u@\h\[`tput sgr0`\]:$PWD$(__git_ps1)$(__screen_info)\n\$ '
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
	alias tsv_to_csv='python3 -c "import sys; import csv; tabin = csv.reader(sys.stdin, dialect=csv.excel_tab); commaout = csv.writer(sys.stdout, dialect=csv.excel); list(commaout.writerow(row) for row in tabin);"'
	alias httpserver='python3 -m http.server'
	if [ -d ${HOME}/.local/lib/python3.*/site-packages/dg ] ; then
			alias dg="python3 -m dg"
	fi
fi

if which syncthing &> /dev/null ; then
    alias syncthing="syncthing -no-browser"
fi

if which stack &> /dev/null ; then
	eval "$(stack --bash-completion-script stack)"
fi

if [ -n "$UNDER_JHBUILD" ]; then
    PS1="[jhbuild] $PS1"
fi

if which ddgr &> /dev/null ; then
	alias websearch="ddgr --np -x"
fi

if which ffmpeg &> /dev/null ; then
	recode-audio () {
		for video in "$@"
		do
			extension="${video##*.}"
			ffmpeg -i "${video}" -max_muxing_queue_size 9999 -vcodec copy "${video}.newaudio.${extension}" && mv "${video}" "${video}.bak" && mv "${video}.newaudio.${extension}" "${video}"
		done
	}
	recode-720p () {
		for video in "$@"
		do
			extension="${video##*.}"
			ffmpeg -i "${video}" -max_muxing_queue_size 9999 -vf scale=1280:720 -c:v libx264 -crf 20 -preset slow -c:a copy "${video}.720p.${extension}" && mv "${video}" "${video}.bak" && mv "${video}.720p.${extension}" "${video}"
		done
	}
	recode-1080p () {
		for video in "$@"
		do
			extension="${video##*.}"
			ffmpeg -i "${video}" -max_muxing_queue_size 9999 -vf scale=1920:1080 -c:v libx264 -crf 20 -preset slow -c:a copy "${video}.1080p.${extension}" && mv "${video}" "${video}.bak" && mv "${video}.1080p.${extension}" "${video}"
		done
	}
fi

if [ ! -f /sbin/clusterctrl ]; then
    alias clusterctrl='ssh cnat.local /sbin/clusterctrl'
fi

alias remove_trailing_spaces="sed --in-place 's/[[:space:]]\+$//'"
alias e="echo"
alias g="git"

conditional-ssh-args () {
	if which ping &> /dev/null && which arp &> /dev/null ; then
		ping -c 1 -W 1 ${1} &> /dev/null
		if ! arp | grep -i "${2}" &> /dev/null ; then
			echo -e "-J ${3}"
		fi
	fi
}

alias issh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
alias ssh-home='ssh -J root@mwhome.hopto.org'
alias scp-home='scp -J root@mwhome.hopto.org'
alias ssh-work='ssh -J dbs1.informatik.uni-halle.de'
alias scp-work='scp -J dbs1.informatik.uni-halle.de'
complete -F _known_hosts issh
complete -F _known_hosts ssh-home
complete -F _known_hosts ssh-work

export NVM_DIR="${HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend
# Save multi-line commands as one command
shopt -s cmdhist
HISTSIZE=500000
HISTFILESIZE=100000
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"
PROMPT_COMMAND='history -a'
# Avoid duplicate entries
HISTCONTROL="erasedups:ignoreboth:rawhistory"
export HH_CONFIG=hicolor,prompt-bottom
# if this is interactive shell, then bind hh to Ctrl-r (for Vi mode check doc)
if which hh &> /dev/null ; then
	if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hh -- \C-j"'; fi
fi

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
HISTTIMEFORMAT='%F %T '

if [[ $- == *i* ]] ; then # If shell is interactive
	# Enable history expansion with space
	# E.g. typing !!<space> will replace the !! with your last command
	bind Space:magic-space

	# Enable incremental history search with up/down arrows (also Readline goodness)
	# Learn more about this here: http://codeinthehole.com/writing/the-most-important-command-line-tip-incremental-history-searching-with-inputrc/
	bind '"\e[A": history-search-backward'
	bind '"\e[B": history-search-forward'
	bind '"\e[C": forward-char'
	bind '"\e[D": backward-char'

	## SMARTER TAB-COMPLETION (Readline bindings) ##

	# Perform file completion in a case insensitive fashion
	bind "set completion-ignore-case on"

	# Treat hyphens and underscores as equivalent
	bind "set completion-map-case on"

	# Display matches for ambiguous patterns at first tab press
	bind "set show-all-if-ambiguous on"

	# Immediately add a trailing slash when autocompleting symlinks to directories
	bind "set mark-symlinked-directories on"
fi

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
alias rm='rm -v'
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

###-tns-completion-start-###
if [ -f /home/maweki/.tnsrc ]; then
    source /home/maweki/.tnsrc
fi
###-tns-completion-end-###
