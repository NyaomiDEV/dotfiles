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

_platform=$(uname)
case $_platform in
	Linux)
		;;
	Darwin)
		export PATH="/opt/local/bin:/opt/local/sbin:/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/3.1.0/bin:$PATH"
		export MANPATH="/opt/local/share/man:$MANPATH"
		;;
esac

export EDITOR=nano
