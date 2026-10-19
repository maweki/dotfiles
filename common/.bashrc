#! /bin/bash
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# check if function exists and define empty one if doesn't
if ! declare -F __vte_prompt_command > /dev/null ; then
    function __vte_prompt_command(){
        return 0
    }
fi

# User specific environment and startup programs

# pathadd [-a] DIR [VAR]: put DIR at the front (-a: the end) of VAR (default
# PATH), moving it there if it's already in it. Nonexistent DIRs are skipped,
# so re-sourcing this file doesn't grow the variable.
pathadd () {
  local append=
  [ "$1" = -a ] && { append=1; shift; }
  local dir=$1 var=${2:-PATH}
  [ -d "$dir" ] || return 0
  local cur=":${!var}:"
  while [[ $cur == *":$dir:"* ]] ; do
    cur=${cur//":$dir:"/:}
  done
  cur=${cur#:} ; cur=${cur%:}
  if [ -n "$append" ] ; then
    cur=${cur:+$cur:}$dir
  else
    cur=$dir${cur:+:$cur}
  fi
  export "$var=$cur"
}

pathadd "$HOME/.cabal/bin"
pathadd "$HOME/.cargo/bin"

if [ -d "${HOME}/.local/android/sdk" ] ; then
  export ANDROID_HOME=${HOME}/.local/android/sdk
  pathadd -a "$ANDROID_HOME/tools"
  pathadd -a "$ANDROID_HOME/platform-tools"
fi

if [[ "${container}" = "podman" || "${container}" = "oci" ]] ; then
  # prefer "system" installation from the container
  pathadd -a "$HOME/.local/bin"
  # set the hostname from tb-create, but only call sudo if it isn't set yet
  # ($HOSTNAME can't be used: toolbox passes in the host's)
  if [ -r /etc/hostname.toolbox ] ; then
    read -r __tb_hostname < /etc/hostname.toolbox
    read -r __tb_current < /proc/sys/kernel/hostname
    [ "$__tb_current" = "$__tb_hostname" ] || sudo hostname -F /etc/hostname.toolbox
    unset __tb_hostname __tb_current
  fi
else
  pathadd "$HOME/.local/bin"
fi
pathadd -a "$HOME/.local/lib" LD_LIBRARY_PATH


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
  fi
  if  ! command -v docker-compose &> /dev/null ; then
    alias docker-compose='podman-compose'
  fi
fi

export EDITOR=nano

# nvm (loaded here so node/npm also work in ssh host cmd)
if [ -n "${XDG_CONFIG_HOME-}" ] ; then
  export NVM_DIR=$XDG_CONFIG_HOME/nvm
else
  export NVM_DIR=$HOME/.nvm
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Everything above is also needed by non-interactive shells (ssh host cmd,
# scp, rsync, scripts sourcing ~/.bashrc such as wrappers made by older
# tb-create-with-command). Everything below is for interactive use only.
[[ $- == *i* ]] || return 0

# bash-completion: Fedora loads it via /etc/bashrc, Debian only from its
# default ~/.bashrc, so load it here if that hasn't happened yet
if [ -z "${BASH_COMPLETION_VERSINFO-}" ] && ! shopt -oq posix ; then
  for f in /usr/share/bash-completion/bash_completion /etc/bash_completion ; do
    [ -r "$f" ] && { . "$f" ; break ; }
  done
  unset f
fi

# __prompt_command_add CMD: run CMD before every prompt, only added once so
# re-sourcing this file is harmless. PROMPT_COMMAND is an array since bash 5.1.
__prompt_command_add () {
  local c
  if (( BASH_VERSINFO[0] * 100 + BASH_VERSINFO[1] >= 501 )) ; then
    for c in "${PROMPT_COMMAND[@]}" ; do
      [[ $c == "$1" ]] && return 0
    done
    PROMPT_COMMAND+=("$1")
  elif [[ "; $PROMPT_COMMAND; " != *"; $1; "* ]] ; then
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }$1"
  fi
}

# colorful prompt: user@host green after success, red after failure.
# Colors and the SSH tag are looked up once instead of on every prompt.
__ps1_status=("$(tput setaf 2 2> /dev/null)" "$(tput setaf 1 2> /dev/null)")
__ps1_reset=$(tput sgr0 2> /dev/null)
__ps1_ssh=${SSH_CLIENT:+[SSH] }
# The prompt is __ps1_pre + git info + __ps1_post. __ps1_update builds it
# before every prompt; __git_ps1 in this mode runs without a subshell.
# Set __ps1_nogit to leave out the git info.
__ps1_pre='\[${__ps1_status[$?>0]}\]${__ps1_ssh}\u@\h\[${__ps1_reset}\]:$PWD'
__ps1_post='${__screen_info_str}\n\$ '
__ps1_update () {
  if [ -z "${__ps1_nogit-}" ] && declare -F __git_ps1 > /dev/null ; then
    __git_ps1 "$__ps1_pre" "$__ps1_post"
  else
    PS1=$__ps1_pre$__ps1_post
  fi
}
__ps1_update
__prompt_command_add __ps1_update

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
  # key help shown in the prompt inside screen; built once, with the color
  # codes marked as non-printing (\001..\002) for readline
  __screen_help=
  if [[ $TERM == screen || $TERM == screen.* ]] ; then
    __screen_help=$(
      r=$'\001'$(tput rev)$'\002' n=$'\001'$(tput sgr0)$'\002'
      g=$'\001'$(tput setaf 2)$'\002' e=$'\001'$(tput setaf 1)$'\002'
      printf '%s' " {C-a ${r}d${n}etach / splitR${g}-${e}| ${r}${g}S${e}|${n} / removeR ${r}X${n} / ${r}c${n}reateW / ${r}k${n}illW / Wlist ${r}\"${n} / copy ${r}esc${n} / terminate ${r}\\${n}}"
    ) 2> /dev/null
  fi
  # runs before every prompt: help + detached sessions. A detached session's
  # socket lacks the owner execute bit. Reading that needs stat (test -x is
  # unreliable as root), but it only runs when there are sessions at all.
  __screen_dir=${SCREENDIR:-/run/screen/S-${USER:-$(id -un)}}
  __screen_info () {
    local socks=("$__screen_dir"/*) mode name detached=
    if [ -e "${socks[0]}" ] ; then
      while read -r mode name ; do
        name=${name##*/}
        [[ ${mode:3:1} == - && -d /proc/${name%%.*} ]] && detached+=" $name"
      done <<< "$(stat -c '%A %n' -- "${socks[@]}" 2> /dev/null)"
    fi
    __screen_info_str=$__screen_help${detached:+ detached:[${detached# }]}
  }
  __prompt_command_add __screen_info
fi

if command -v git &> /dev/null ; then
    alias g="git"

    # git prompt (__git_ps1): Fedora, Debian
    if ! declare -F __git_ps1 &> /dev/null ; then
      for f in /usr/share/git-core/contrib/completion/git-prompt.sh /usr/lib/git-core/git-sh-prompt ; do
        [ -r "$f" ] && { . "$f" ; break ; }
      done
      unset f
    fi

    # git completion is loaded on demand by bash-completion, but completing
    # the g alias needs it now. Without bash-completion, source it directly.
    if ! declare -F __git_complete &> /dev/null ; then
      if declare -F _comp_load &> /dev/null ; then
        _comp_load git
      elif declare -F __load_completion &> /dev/null ; then
        __load_completion git
      elif [ -r /usr/share/bash-completion/completions/git ] ; then
        . /usr/share/bash-completion/completions/git
      fi
    fi

    export GIT_PS1_SHOWDIRTYSTATE=1

    if declare -F __git_complete &> /dev/null ; then
      __git_complete g __git_main
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
alias lowprio="$lowprio"
unset lowprio

if command -v flatpak &> /dev/null ; then
  declare -A fpapps
  fpapps[eog]=org.gnome.eog
  fpapps[evince]=org.gnome.Evince
  fpapps[gedit]=org.gnome.gedit
  fpapps[libreoffice]=org.libreoffice.LibreOffice
  fpapps[vlc]=org.videolan.VLC
  fpapps[zotero]=org.zotero.Zotero
  # alias commands that aren't installed natively to their installed flatpak
  fplist=$'\n'$(flatpak list --app --columns=application)$'\n'
  for fpcmd in "${!fpapps[@]}"; do
    if ! command -v "$fpcmd" &> /dev/null && [[ $fplist == *$'\n'"${fpapps[$fpcmd]}"$'\n'* ]] ; then
      alias "$fpcmd=flatpak run ${fpapps[$fpcmd]}"
    fi
  done
  unset fpapps fplist fpcmd
fi

anon () {
  __ps1_pre='\[${__ps1_status[$?>0]}\]\W\[${__ps1_reset}\]'
  __ps1_post=' \$ '
  __ps1_nogit=1
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
# host completion comes from bash-completion
if declare -F _known_hosts &> /dev/null ; then
  complete -F _known_hosts issh
  complete -F _known_hosts ssh-home
  complete -F _known_hosts ssh-work
fi

if [ -s "$NVM_DIR/nvm.sh" ]; then
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
else
  # install the latest nvm release (as in nvm's manual install) and load it
  nvm-install () {
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR" &&
    ( cd "$NVM_DIR" &&
      git checkout -q "$(git describe --abbrev=0 --tags --match 'v[0-9]*' "$(git rev-list --tags --max-count=1)")" ) &&
    \. "$NVM_DIR/nvm.sh" &&
    \. "$NVM_DIR/bash_completion" &&
    unset -f nvm-install
  }
fi

# Save multi-line commands as one command
shopt -s cmdhist
shopt -s histappend              # append new history items to .bash_history
export HISTCONTROL=ignorespace   # leading space hides commands from history
export HISTFILESIZE=100000       # increase history file size (default is 500)
export HISTSIZE=${HISTFILESIZE}  # increase history size (default is 500)
# ensure synchronization between bash memory and history file
__prompt_command_add 'history -a; history -n'
if command -v hstr &> /dev/null ; then
  alias hh=hstr                    # hh to be alias for hstr
  export HSTR_CONFIG=hicolor       # get more colors
  function hstrnotiocsti {
      { READLINE_LINE="$( { </dev/tty hstr ${READLINE_LINE}; } 2>&1 1>&3 3>&- )"; } 3>&1;
      READLINE_POINT=${#READLINE_LINE}
  }
  # bind hstr to Ctrl-r (for Vi mode check doc)
  bind -x '"\C-r": "hstrnotiocsti"'
  export HSTR_TIOCSTI=n
fi


# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
HISTTIMEFORMAT='%F %T '

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
# (only when writing to a terminal, so it doesn't end up in pipes and files)
[ -t 1 ] && printf "\033]777;container;pop;;\033\\"

alias nosleep='systemd-inhibit --what=sleep --why="SSH session" sleep infinity'

# color everything
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias grep='grep --color=auto'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias lsd='ls -tl'
alias lss='ls -Sl'
alias ..='cd ..'
alias rm='rm -v'
alias xzegrep='xzgrep -E --color=auto'
alias xzfgrep='xzgrep -F --color=auto'
alias xzgrep='xzgrep --color=auto'
alias zegrep='zgrep -E --color=auto'
alias zfgrep='zgrep -F --color=auto'
alias zgrep='zgrep --color=auto'

[ -s ~/.plog.sh ] && source ~/.plog.sh

# bash-completion completes sudo properly (options, then the command's own
# completion); without it, at least complete commands and files
[ -n "${BASH_COMPLETION_VERSINFO-}" ] || complete -cf sudo
