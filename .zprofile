if which brew >/dev/null; then
	eval $(brew shellenv)
elif [ -d /opt/homebrew/bin ]; then
	eval $(/opt/homebrew/bin/brew shellenv)
fi

emulate sh
. ~/.profile
emulate zsh
