if [ -d "$HOME/.local/bin" ]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

if which yarn >/dev/null; then
	export PATH="$(yarn global bin):$PATH"
fi

if [ -f "$HOME/.cargo/env" ]; then
	source $HOME/.cargo/env
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
		export PATH="/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/3.1.0/bin:$PATH"
		;;
esac

export EDITOR=nano
