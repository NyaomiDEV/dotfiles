if [ -d "$HOME/.local/bin" ]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

if which yarn >/dev/null; then
	export PATH="$(yarn global bin):$PATH"
fi

if [ -f "$HOME/.cargo/env" ]; then
	source $HOME/.cargo/env
fi

if [ -d "$HOME/.deno" ]; then
 	export DENO_INSTALL="$HOME/.deno"
	export PATH="$DENO_INSTALL/bin:$PATH"
fi

if which brew >/dev/null; then
	eval $(brew shellenv)
elif [ -d /opt/homebrew/bin ]; then
	eval $(/opt/homebrew/bin/brew shellenv)
fi

_platform=$(uname)
case $_platform in
	Linux)
		export VDPAU_DRIVER=va_gl
		if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
			export MOZ_ENABLE_WAYLAND=1
			export MOZ_DBUS_REMOTE=1
		fi
		;;
	Darwin)
		export PATH="/opt/local/bin:/opt/local/sbin:/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/3.1.0/bin:$PATH"
		export MANPATH="/opt/local/share/man:$MANPATH"
		;;
esac

export EDITOR=nano
