# Load plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Enable colors
autoload -U colors && colors

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

# Alias ls utils to show color
alias ls='ls --color=auto'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'

# Enable command line editing in $EDITOR and bind to Ctrl+F, c keys
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^Fc' edit-command-line

# Prompt
PS1="%{$fg[yellow]%}%n@%{$fg[magenta]%}%M%{$fg[green]%}%~%{$reset_color%}%% "

# History
HISTSIZE=10000
SAVEHIST=10000
[ -d "$HOME/.cache/zsh" ] || mkdir -p "$HOME/.cache/zsh"
HISTFILE=~/.cache/zsh/history

setopt append_history
setopt inc_append_history
setopt share_history
setopt extended_history
setopt hist_reduce_blanks
setopt hist_ignore_space
setopt hist_ignore_all_dups
export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# Allow comments
setopt interactive_comments

# Correct incorrect command names
setopt correct

# Yeet the beeper
setopt no_beep

# Tab complete
autoload -U compinit

#
# This section is mainly copied over from https://github.com/seebi/zshrc/blob/master/completion.zsh
#

# auto rehash commands
# http://www.zsh.org/mla/users/2011/msg00531.html
zstyle ':completion:*' rehash true

# for all completions: menuselection
zstyle ':completion:*' menu select=1

# for all completions: grouping the output
zstyle ':completion:*' group-name ''

# for all completions: color
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=1\;30\;47

# completion of .. directories
zstyle ':completion:*' special-dirs true

# fault tolerance
zstyle ':completion:*' completer _complete _correct _approximate
# (1 error on 3 characters)
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'

# case insensitivity TODO: Add italian common accents kthxbye
zstyle ":completion:*" matcher-list 'm:{A-Zöäüa-zÖÄÜ}={a-zÖÄÜA-Zöäü}'

# for all completions: grouping / headline / ...
zstyle ':completion:*:messages' format $'\e[01;35m -- %d -- \e[00;00m'
zstyle ':completion:*:warnings' format $'\e[01;31mNo matches found\e[00;00m'
zstyle ':completion:*:descriptions' format $'\e[01;33m -- %d -- \e[00;00m'
zstyle ':completion:*:corrections' format $'\e[01;33m -- %d -- \e[00;00m'

# statusline for many hits
zstyle ':completion:*:default' select-prompt $'\e[01;35m -- %M    %P -- \e[00;00m'

# for all completions: show comments when present
zstyle ':completion:*' verbose yes

# case-insensitive -> partial-word (cs) -> substring completion:
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

#
# And from here it is again original work (TM)
#

# always tab complete, never insert tab
zstyle ':completion:*' insert-tab false

zmodload zsh/complist
compinit -d "$HOME/.cache/zsh/compdump"

# Include hidden files in autocomplete
_comp_options+=(globdots)

# Init cod (completion daemon) if it exists
where cod >/dev/null && source <(cod init $$ zsh)

# Load aliases and shortcuts if existent
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

# Autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#808080"
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Home/end keys go to beginning and end of line
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Moving cursor through words
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Character deletion
bindkey "^?" backward-delete-char
bindkey "${terminfo[kdch1]}" delete-char # Delete

# Overwrite mode
bindkey "${terminfo[kich1]}" overwrite-mode # Insert

# History navigation
bindkey "${terminfo[kpp]}" beginning-of-history # PgUp
bindkey "${terminfo[knp]}" end-of-history       # PgDn

# Incremental search
bindkey "^r" history-incremental-search-backward
bindkey "^s" history-incremental-search-forward

#
# Fish-like directory traversing
# https://github.com/romkatv/powerlevel10k/issues/663
# BEGIN
#
setopt AUTO_PUSHD

# Widgets for changing current working directory.
function redraw-prompt() {
	emulate -L zsh
	local f
	for f in chpwd $chpwd_functions precmd $precmd_functions; do
		(( $+functions[$f] )) && $f &>/dev/null
	done
	zle .reset-prompt
	zle -R
}

function cd-rotate() {
	emulate -L zsh
	while (( $#dirstack )) && ! pushd -q $1 &>/dev/null; do
		popd -q $1
	done
	if (( $#dirstack )); then
		redraw-prompt
	fi
}

function cd-back() { cd-rotate +1 }
function cd-forward() { cd-rotate -0 }

zle -N cd-back
zle -N cd-forward

bindkey '^[[1;3D' cd-back     # alt+left   cd into the prev directory
bindkey '^[[1;3C' cd-forward  # alt+right  cd into the next directory
#
# END
#

# Go up, from Andy Kluger (@andykluger) at telegram group @zshell
cd-go-up () {
  emulate -L zsh
  cd ..
  redraw-prompt
}

zle -N cd-go-up

bindkey '^[[1;3A' cd-go-up  # alt+up;  cd into the parent directory

# Load syntax highlighting and substring search as last (not really but this works)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# History substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Highlight colors
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]="fg=white"
ZSH_HIGHLIGHT_STYLES[default]="fg=#e0e0e0"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=orange"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=orange"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=orange"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=orange"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=cyan"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=blue"
ZSH_HIGHLIGHT_STYLES[comment]="fg=grey"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]="fg=#ff0000"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]="fg=#ff0000"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]="fg=#ff0000"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]="fg=#ff0000"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=#ff0000"

# History substring colors
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=white,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,bold'
