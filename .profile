if [ -d "$HOME/.local/bin" ]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

if which yarn; then
	export PATH="$(yarn global bin):$PATH"
fi
