#! /bin/bash
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# check if function exists and define empty one if doesn't
if [[ $(type -t "__vte_prompt_command") != function ]]; then
    function __vte_prompt_command(){
        return 0
    }
fi

# User specific environment and startup programs

if [ -d "${HOME}/.cabal/bin" ] ; then
  PATH=$HOME/.cabal/bin:$PATH
fi

if [ -d "${HOME}/.cargo/bin" ] ; then
  PATH=$HOME/.cargo/bin:$PATH
fi

if [ -d "${HOME}/.local/android/sdk" ] ; then
    export ANDROID_HOME=${HOME}/.local/android/sdk
    export PATH="${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools"
fi

if [[ "${container}" = "podman" || "${container}" = "oci" ]] ; then
  # prefer "system" installation from the container
  export PATH=$PATH:$HOME/.local/bin
  [ -f /etc/hostname.toolbox ] && sudo hostname -F /etc/hostname.toolbox
else
  export PATH=$HOME/.local/bin:$PATH
fi
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}${HOME}/.local/lib


# TZ / LANG
#export TZ="Europe/Berlin"

if command -v podman &> /dev/null ; then
  if command -v toolbox &> /dev/null ; then
    alias tb='toolbox enter -c'
    alias tb-ls='toolbox list'
    alias tb-list='toolbox list'
    tb-help () {
      echo "tb CONTAINER                          enter the toolbox"
      echo "tb-create CONTAINER [INIT CMD...]     create, set hostname CONTAINER-tb, run INIT CMD inside"
      echo "tb-create-with-command CONTAINER CMD [INIT CMD...]"
      echo "                                      tb-create, then add ~/.local/bin/CONTAINER running CMD inside"
      echo "tb-list                               list toolboxes"
      echo "tb-remove CONTAINER...                stop and remove toolboxes"
      echo "tb-run CONTAINER [CMD...]             run CMD (default: CONTAINER) inside"
      echo "tb-run-tmp CMD...                     run CMD in a throwaway toolbox"
      echo "tb-stop CONTAINER...                  stop toolboxes"
    }
    tb-create () {
      [ $# -ge 1 ] || { echo "usage: tb-create CONTAINER [INIT CMD...]" >&2; return 2; }
      local name=$1
      toolbox create -c "$name" &&
      toolbox run -c "$name" sudo sh -c 'echo "$1" > /etc/hostname.toolbox && hostname -F /etc/hostname.toolbox' sh "${name}-tb" || return
      if [ $# -gt 1 ] ; then
        tb-run "$name" "${@:2}"
      fi
    }
    tb-create-with-command () {
      [ $# -ge 2 ] || { echo "usage: tb-create-with-command CONTAINER CMD [INIT CMD...]" >&2; return 2; }
      local name=$1 cmd=$2 wrapper=~/.local/bin/$1
      if [ -e "$wrapper" ] && ! grep -qE 'toolbox run|tb-run' "$wrapper" ; then
        echo "tb-create-with-command: $wrapper exists and is not a toolbox wrapper" >&2
        return 1
      fi
      tb-create "$name" "${@:3}" || return
      mkdir -p ~/.local/bin &&
      printf '#!/bin/bash\n# created by tb-create-with-command\nexec toolbox run -c %q %q "$@"\n' "$name" "$cmd" >| "$wrapper" &&
      chmod +x "$wrapper"
    }
    tb-remove () {
      [ $# -ge 1 ] || { echo "usage: tb-remove CONTAINER..." >&2; return 2; }
      toolbox rm --force "$@"
    }
    tb-stop () {
      [ $# -ge 1 ] || { echo "usage: tb-stop CONTAINER..." >&2; return 2; }
      podman stop "$@" > /dev/null
    }
    tb-run () {
      [ $# -ge 1 ] || { echo "usage: tb-run CONTAINER [CMD...]" >&2; return 2; }
      if [ $# -eq 1 ] ; then
        toolbox run -c "$1" "$1"
      else
        toolbox run -c "$@"
      fi
    }
    tb-run-tmp () {
      [ $# -ge 1 ] || { echo "usage: tb-run-tmp CMD..." >&2; return 2; }
      local name=tmpcont${RANDOM} rc
      tb-create "$name" && tb-run "$name" "$@"
      rc=$?
      tb-remove "$name" > /dev/null
      return $rc
    }
  fi
  if  ! command -v docker &> /dev/null ; then
    alias docker='podman'
    alias docker-compose='podman-compose'
  fi
  if  ! command -v docker-compose &> /dev/null ; then
    alias docker-compose='podman-compose'
  fi
fi

export EDITOR=nano

# Everything above is also needed by non-interactive shells (ssh host cmd,
# scp, rsync, scripts sourcing ~/.bashrc such as wrappers made by older
# tb-create-with-command). Everything below is for interactive use only.
[[ $- == *i* ]] || return 0

# colorful terminal with results color
PS1='\[`[ $? = 0 ] && X=2 || X=1; tput setaf $X`\]`[ ! -z "${SSH_CLIENT}" ] && echo "[SSH] "`\u@\h\[`tput sgr0`\]:$PWD$(__screen_info)\n\$ '

# disable ctrl+s/ctrl+q flow control: ctrl+s no longer freezes the terminal
# (and becomes forward history search)
[ -t 0 ] && stty -ixon

# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
set -o noclobber

# Update window size after every command
shopt -s checkwinsize

# Turn on recursive globbing (enables ** to recurse all directories)
shopt -s globstar

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# start tmux and go from there
#[[ -z $TMUX ]] && command -v tmux &> /dev/null && (exec tmux)

if command -v xdg-open &> /dev/null ; then
  alias x='xdg-open'
fi

if command -v screen &> /dev/null ; then
  alias screenS='screen -S'
  alias screenR='screen -R'
__screen_info () {
if [[ $TERM == screen || $TERM == screen.* ]]; then
    echo -n ' {C-a '
    tput rev; echo -n 'd'; tput sgr0; echo -n 'etach'
    tput sgr0; echo -n " / "
    echo -n 'splitR'; tput setaf 2; echo -n '-'; tput setaf 1; echo -n '| '; tput rev; tput setaf 2; echo -n 'S'; tput setaf 1; echo -n '|'
    tput sgr0; echo -n " / "
    echo -n 'removeR '; tput rev; echo -n "X"
    tput sgr0; echo -n " / "
    tput rev; echo -n 'c'; tput sgr0; echo -n 'reateW'
    tput sgr0; echo -n " / "
    tput rev; echo -n 'k'; tput sgr0; echo -n 'illW'
    tput sgr0; echo -n " / "
    echo -n 'Wlist '; tput rev; echo -n '"'
    tput sgr0; echo -n " / "
    echo -n 'copy '; tput rev; echo -n 'esc'
    tput sgr0; echo -n " / "
    echo -n 'terminate '; tput rev; echo -n '\'
    tput sgr0; echo -n '}'
fi
    __detached=$(pgrep -x screen &> /dev/null && echo -n $(screen -ls | grep Detached | awk -F ' ' '{print $1}'))
    [ -z "${__detached}" ] || (echo -n " detached:["; echo -n "${__detached}"; echo -n "]")
}
else
__screen_info () {
  return
}
fi

if command -v git &> /dev/null ; then
    alias g="git"

    # adding git completion and info
    [ -s /usr/share/git-core/contrib/completion/git-prompt.sh ] && source /usr/share/git-core/contrib/completion/git-prompt.sh
    [ -s /usr/share/bash-completion/completions/git ] && source /usr/share/bash-completion/completions/git
    [ -s /etc/bash_completion.d/git-prompt ] && source /etc/bash_completion.d/git-prompt
    [ -s /etc/bash_completion.d/git ] && source /etc/bash_completion.d/git
    [ -s /etc/bash_completion.d/git-flow-completion.bash ] && source /etc/bash_completion.d/git-flow-completion.bash

    export GIT_PS1_SHOWDIRTYSTATE=1

    if __git_ps1 &> /dev/null ; then
        PS1='\[`[ $? = 0 ] && X=2 || X=1; tput setaf $X`\]`[ ! -z "${SSH_CLIENT}" ] && echo "[SSH]"`\u@\h\[`tput sgr0`\]:$PWD$(__git_ps1)$(__screen_info)\n\$ '
    fi

    if command -v __git_wrap__git_main &> /dev/null ; then
        complete -o bashdefault -o default -o nospace -F __git_wrap__git_main g
    fi

    gitstashpullpop () {
      git stash && git pullr && git stash pop
    }
fi

if command -v nq &> /dev/null ; then
  mkdir -p /tmp/nq &> /dev/null
  export NQDIR=/tmp/nq
  alias q=nq
fi
if command -v tsp &> /dev/null ; then
  alias q=tsp
fi

# offer to install zed on first use, but only in graphical sessions
if ! command -v zed &> /dev/null && [ -n "${WAYLAND_DISPLAY}${DISPLAY}" ] ; then
  zed () {
    local reply
    read -rp "zed is not installed. Install it from zed.dev now? [y/N] " reply
    [[ $reply == [yY]* ]] || return 1
    curl -fsSL https://zed.dev/install.sh | sh && unset -f zed && hash -r
  }
fi

if ( command -v chrt && chrt -m | grep SCHED_IDLE | grep "0/0" ) &> /dev/null ; then
  lowprio="ionice -c3 -t chrt -i 0"
else
  lowprio="nice"
fi
alias lowprio=$lowprio

if command -v flatpak &> /dev/null ; then
  declare -A fpapps
  fpapps[atom]=io.atom.Atom
  fpapps[eog]=org.gnome.eog
  fpapps[evince]=org.gnome.Evince
  fpapps[gedit]=org.gnome.gedit
  fpapps[libreoffice]=org.libreoffice.LibreOffice
  fpapps[vlc]=org.videolan.VLC
  fpapps[zotero]=org.zotero.Zotero
  fplist=`flatpak list --app --columns=application`
  for fpcmd in "${!fpapps[@]}"; do
    if ! command -v ${fpcmd} &> /dev/null && (echo "${fplist}" | grep ${fpapps[${fpcmd}]} &> /dev/null) ; then
      alias ${fpcmd}="flatpak run ${fpapps[${fpcmd}]}"
    fi
  done
fi

anon () {
  PS1='\[`[ $? = 0 ] && X=2 || X=1; tput setaf $X`\]\W\[`tput sgr0`\] \$ '
  reset
}

re-tmp () {
  [ -n "$1" ] || { echo "usage: re-tmp <size-in-GB>" >&2; return 1; }
  sudo mount -o remount,size="${1}G",noatime /tmp &&
  sudo setquota -u "$USER" 0 0 0 0 /tmp
}

if command -v python3 &> /dev/null ; then
  alias pp='python3 -mjson.tool'
  alias sum='python3 -c "import sys; print(sum(int(l) for l in sys.stdin))"'
  alias sumf='python3 -c "import sys; print(sum(float(l) for l in sys.stdin))"'
  alias tsv_to_csv='python3 -c "import sys; import csv; tabin = csv.reader(sys.stdin, dialect=csv.excel_tab); commaout = csv.writer(sys.stdout, dialect=csv.excel); list(commaout.writerow(row) for row in tabin);"'
  alias httpserver='python3 -m http.server'
fi

if command -v syncthing &> /dev/null ; then
    alias syncthing="syncthing -no-browser"
fi

if command -v stack &> /dev/null ; then
  eval "$(stack --bash-completion-script stack)"
fi

if [ -n "$UNDER_JHBUILD" ]; then
    PS1="[jhbuild] $PS1"
fi

alias websearch="ddgr --np -x"

if command -v ffmpeg &> /dev/null ; then
  recode-audio () {
    for video in "$@"
    do
      extension="${video##*.}"
      ffmpeg -nostdin -i "${video}" -max_muxing_queue_size 9999 -vcodec copy -c:s mov_text "${video}.newaudio.${extension}" && mv "${video}" "${video}.bak" && mv "${video}.newaudio.${extension}" "${video}"
    done
  }
  recode-720p () {
    for video in "$@"
    do
      extension="${video##*.}"
      lowprio ffmpeg -nostdin -i "${video}" -max_muxing_queue_size 9999 -vf scale=1280:720 -c:v libx264 -crf 20 -preset slow -c:s copy -c:a copy "${video}.720p.${extension}" && mv "${video}" "${video}.bak" && mv "${video}.720p.${extension}" "${video}"
    done
  }
  recode-1080p () {
    for video in "$@"
    do
      extension="${video##*.}"
      lowprio ffmpeg -nostdin -i "${video}" -max_muxing_queue_size 9999 -vf scale=1920:1080 -c:v libx264 -crf 20 -preset slow -c:s copy -c:a copy "${video}.1080p.${extension}" && mv "${video}" "${video}.bak" && mv "${video}.1080p.${extension}" "${video}"
    done
  }
  animated-gif () {
    for video in "$@"
    do
      ffmpeg -nostdin -i "${video}" -vf "fps=24,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop -1 "${video}.gif"
    done
  }
  recode-mp3 () {
    for video in "$@"
    do
      ffmpeg -nostdin -i "${video}" -b:a 192K -vn "${video}.mp3"
    done
  }
fi

alias remove_trailing_spaces="sed --in-place 's/[[:space:]]\+$//'"
alias e="echo"

alias issh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
alias ssh-home='ssh -J root@home.maweki.de'
alias scp-home='scp -J root@home.maweki.de'
alias socks-home='ssh -TND 1080 root@home.maweki.de'
alias ssh-garten='ssh -p 10022 root@maweki.de'
alias socks-garten='ssh -p 10022 -TND 1080 root@maweki.de'
alias ssh-work='ssh -J dbs1.informatik.uni-halle.de'
alias scp-work='scp -J dbs1.informatik.uni-halle.de'
alias socks-work='ssh -TND 1080 dbs1.informatik.uni-halle.de'
complete -F _known_hosts issh
complete -F _known_hosts ssh-home
complete -F _known_hosts ssh-work

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
if [ -s "$NVM_DIR/nvm.sh" ]; then
\. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
else
  nvm-install () {
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    pushd "$NVM_DIR" && \
    git fetch --tags && \
    git checkout `git tag -l --sort=taggerdate | tail -1` && \
    popd
  }
fi

# Save multi-line commands as one command
shopt -s cmdhist
shopt -s histappend              # append new history items to .bash_history
export HISTCONTROL=ignorespace   # leading space hides commands from history
export HISTFILESIZE=100000       # increase history file size (default is 500)
export HISTSIZE=${HISTFILESIZE}  # increase history size (default is 500)
# ensure synchronization between bash memory and history file
export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"
if command -v hstr &> /dev/null ; then
  alias hh=hstr                    # hh to be alias for hstr
  export HSTR_CONFIG=hicolor       # get more colors
  function hstrnotiocsti {
      { READLINE_LINE="$( { </dev/tty hstr ${READLINE_LINE}; } 2>&1 1>&3 3>&- )"; } 3>&1;
      READLINE_POINT=${#READLINE_LINE}
  }
  # if this is interactive shell, then bind hstr to Ctrl-r (for Vi mode check doc)
  if [[ $- =~ .*i.* ]]; then bind -x '"\C-r": "hstrnotiocsti"'; fi
  export HSTR_TIOCSTI=n
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

  # disable container tracking https://github.com/containers/toolbox/issues/218
  printf "\033]777;container;pop;;\033\\"
fi

alias nosleep='systemd-inhibit --what=sleep --why="SSH session" sleep infinity'

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

###-tns-completion-start-###
if [ -f /home/maweki/.tnsrc ]; then
    source /home/maweki/.tnsrc
fi
###-tns-completion-end-###
