# .bash_profile

if [ -n "$DESKTOP_SESSION" ];then
	eval $(gnome-keyring-daemon --start)
	export SSH_AUTH_SOCK
fi

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi
