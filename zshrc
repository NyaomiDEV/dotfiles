# Naomi's dotfiles -- .zshrc
# Z Shell Configuration file

#
# Prep work
#

[ -d "$HOME/.cache/zsh" ] || mkdir -p "$HOME/.cache/zsh"

#
# Aliases
#

# Alias ls utils to show color
alias ls='ls --color=auto'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'

# if bat is present, alias cat to use bat -pp
where bat >/dev/null && alias cat="bat -pp"

# Load aliases and shortcuts if existent
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

#
# Autoloads
#

# Colors
autoload -U colors

# Completion
autoload -U compinit

# Edit command line
autoload -U edit-command-line

#
# Colors
#

# Invoke colors
colors

# Calculate and import dircolors
if where dircolors >/dev/null ; then
	if [[ -f ~/.dir_colors ]] ; then
		eval $(dircolors -b ~/.dir_colors)
	elif [[ -f /etc/DIR_COLORS ]] ; then
		eval $(dircolors -b /etc/DIR_COLORS)
	else
		eval $(dircolors)
	fi
fi

# Highlight colors
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]="fg=white,bold"
ZSH_HIGHLIGHT_STYLES[default]="fg=white"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=orange"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=orange"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=orange"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=orange"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=cyan"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=blue"
ZSH_HIGHLIGHT_STYLES[comment]="fg=grey"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]="fg=red"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]="fg=red"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]="fg=red"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]="fg=red"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=red"

# History substring colors
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=white,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,bold'

# Selected item in menu list color
SELECTED_ITEM_MENULIST_COLOR="1;30;47"

#
# Options
#

# Beeper
setopt no_beep

# Comments
setopt interactive_comments

# Correct incorrect command names
setopt correct

# Directory stack
setopt auto_pushd

# History
setopt append_history
setopt inc_append_history
setopt share_history
setopt extended_history
setopt hist_reduce_blanks
setopt hist_ignore_space
#setopt hist_ignore_all_dups

# Prompt
setopt promptsubst

#
# Variables
#

# Autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#808080"
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Completion
_comp_options+=(globdots) # Include hidden files

# Directory stack
DIRSTACKSIZE=10

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# Prompt
# If you want a barebones classic prompt style, uncomment the following line and comment everything else
# PS1="%{$fg[yellow]%}%n@%{$fg[magenta]%}%M%{$fg[green]%}%~%{$reset_color%}%% "
# Source: Andy Kluger (@andykluger) from telegram group @zshell
# Readapted to my use case
local segments=()
segments+='%(?..%F{red}[%?]%f )' # retcode if non-zero
segments+='%F{green}%~ ' # folder
segments+='$(git-prompt-info)' # git info
segments+='%F{white}%(!.'$'\n''#.'$'\n'')%%%f ' # prompt symbol
PS1=${(j::)segments}

#
# Functions
#

# Source: Andy Kluger (@andykluger) from telegram group @zshell
function git-prompt-info () {
    local gitref=${$(git branch --show-current 2>/dev/null):-$(git rev-parse --short HEAD 2>/dev/null)}
    print -rP -- "%F{blue}${gitref}%F{red}${$(git status --porcelain 2>/dev/null):+*}%f"
}

# Source: https://github.com/romkatv/powerlevel10k/issues/663
function redraw-prompt () {
	emulate -L zsh
	local f
	for f in chpwd $chpwd_functions precmd $precmd_functions; do
		(( $+functions[$f] )) && $f &>/dev/null
	done
	zle .reset-prompt
	zle -R
}

# Source: https://github.com/romkatv/powerlevel10k/issues/663
function cd-rotate () {
	emulate -L zsh
	while (( $#dirstack )) && ! pushd -q $1 &>/dev/null; do
		popd -q $1
	done
	if (( $#dirstack )); then
		redraw-prompt
	fi
}

# Source: https://github.com/romkatv/powerlevel10k/issues/663
function cd-back () {
	cd-rotate +1
}

# Source: https://github.com/romkatv/powerlevel10k/issues/663
function cd-forward () {
	cd-rotate -0
}

# Source: Andy Kluger (@andykluger) from telegram group @zshell
function cd-up () {
  emulate -L zsh
  cd ..
  redraw-prompt
}

#
# ZLE Widgets
#

# Edit command line
zle -N edit-command-line

# Directory navigation
zle -N cd-up
zle -N cd-back
zle -N cd-forward

#
# Plugin loads (custom order)
#

# Autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# History substring search
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

#
# Keybinds
#

# Commandline editing
bindkey '^Fc' edit-command-line # Ctrl+F, c

# Line navigation
bindkey '^[[H' beginning-of-line # Home
bindkey '^[[F' end-of-line # End
bindkey "^[[1;5C" forward-word # Ctrl+Right
bindkey "^[[1;5D" backward-word # Ctrl+Left

# Character deletion
bindkey "^?" backward-delete-char
bindkey "${terminfo[kdch1]}" delete-char # Delete

# Overwrite mode
bindkey "${terminfo[kich1]}" overwrite-mode # Insert

# History navigation
bindkey "${terminfo[kpp]}" beginning-of-history # PgUp
bindkey "${terminfo[knp]}" end-of-history       # PgDn
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Incremental search
bindkey "^r" history-incremental-search-backward
bindkey "^s" history-incremental-search-forward

# Directory traversing
bindkey '^[[1;3D' cd-back     # Alt+Left
bindkey '^[[1;3C' cd-forward  # Alt+Right
bindkey '^[[1;3A' cd-up       # Alt+Up

#
# Completion setup
# This section is mainly copied over from https://github.com/seebi/zshrc/blob/master/completion.zsh
#

# Always tab complete
zstyle ':completion:*' insert-tab false

# Automatically rehash commands // Source: http://www.zsh.org/mla/users/2011/msg00531.html
zstyle ':completion:*' rehash true

# Case insensitivity
# TODO: Add italian common accents
zstyle ":completion:*" matcher-list 'm:{A-Zöäüa-zÖÄÜ}={a-zÖÄÜA-Zöäü}'

# Case Insensitive -> Partial Word (cs) -> Substring completion
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Colors
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=${SELECTED_ITEM_MENULIST_COLOR}

# Comments
zstyle ':completion:*' verbose yes

# Fault tolerance (1 error on 3 characters)
zstyle ':completion:*' completer _complete _correct _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'

# Grouping
zstyle ':completion:*' group-name ''
zstyle ':completion:*:messages' format $'\e[01;35m -- %d -- \e[00;00m'
zstyle ':completion:*:warnings' format $'\e[01;31mNo matches found\e[00;00m'
zstyle ':completion:*:descriptions' format $'\e[01;33m -- %d -- \e[00;00m'
zstyle ':completion:*:corrections' format $'\e[01;33m -- %d -- \e[00;00m'

# Menu selection
zstyle ':completion:*' menu select=1

# Special directories
zstyle ':completion:*' special-dirs true

# Status line
zstyle ':completion:*:default' select-prompt $'\e[01;35m -- %M    %P -- \e[00;00m'

zmodload zsh/complist
compinit -d "$HOME/.cache/zsh/compdump"

# Use cod (completion daemon) if it is available in the system
where cod >/dev/null && source <(cod init $$ zsh)
