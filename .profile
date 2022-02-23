if [ -d "$HOME/.local/bin" ]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

if which yarn >/dev/null; then
	export PATH="$(yarn global bin):$PATH"
fi

if [ $(uname) = "Linux" ]; then
	export VDPAU_DRIVER=va_gl
fi
