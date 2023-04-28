if which brew >/dev/null; then
	eval $(brew shellenv)
elif [ -d /opt/homebrew/bin ]; then
	eval $(/opt/homebrew/bin/brew shellenv)
fi

emulate sh
. ~/.profile
emulate zsh

##
# Your previous /Users/naomi/.zprofile file was backed up as /Users/naomi/.zprofile.macports-saved_2022-09-13_at_14:06:14
##

# MacPorts Installer addition on 2022-09-13_at_14:06:14: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.


# MacPorts Installer addition on 2022-09-13_at_14:06:14: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH="/opt/local/share/man:$MANPATH"
# Finished adapting your MANPATH environment variable for use with MacPorts.

