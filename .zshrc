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

# If bat is present, alias cat to use bat -pp
where bat >/dev/null && alias cat="bat -pp" || true

# Load aliases and shortcuts if existent
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

#
# Modules and functions loading
#

# Add ZSH Hook
autoload -U add-zsh-hook

# Colors
autoload -U colors

# Completion
autoload -U compinit
zmodload zsh/complist

# Edit command line
autoload -U edit-command-line

# Zpty
zmodload zsh/zpty

#
# Colors
#

# Invoke colors
colors

# Calculate and import dircolors
if where dircolors >/dev/null; then
	if [[ -f ~/.dir_colors ]]; then
		eval $(dircolors -b ~/.dir_colors)
	elif [[ -f /etc/DIR_COLORS ]]; then
		eval $(dircolors -b /etc/DIR_COLORS)
	else
		eval $(dircolors)
	fi
fi

# Highlight colors
typeset -A HIGHLIGHT_STYLES

HIGHLIGHT_STYLES[default]="none"

HIGHLIGHT_STYLES[reserved-word]="fg=yellow,bold"

HIGHLIGHT_STYLES[precommand]="fg=white,bold"
HIGHLIGHT_STYLES[command]="fg=white,bold"
HIGHLIGHT_STYLES[commandseparator]="fg=cyan"

HIGHLIGHT_STYLES[alias]="fg=green,bold"
HIGHLIGHT_STYLES[suffix-alias]="fg=green"
HIGHLIGHT_STYLES[global-alias]="fg=green,bold"

HIGHLIGHT_STYLES[builtin]="fg=blue,bold"

HIGHLIGHT_STYLES[function]="fg=magenta,bold"

HIGHLIGHT_STYLES[redirection]="fg=blue"

HIGHLIGHT_STYLES[comment]="fg=black"

HIGHLIGHT_STYLES[single-hyphen-option]="none"
HIGHLIGHT_STYLES[double-hyphen-option]="none"

HIGHLIGHT_STYLES[single-quoted-argument]="fg=orange"
HIGHLIGHT_STYLES[double-quoted-argument]="fg=orange"
HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=orange"
HIGHLIGHT_STYLES[back-quoted-argument]="fg=orange"

HIGHLIGHT_STYLES[back-quoted-argument-delimiter]="fg=magenta"

HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=orange"
HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=orange"
HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=orange"

HIGHLIGHT_STYLES[single-quoted-argument-unclosed]="fg=red"
HIGHLIGHT_STYLES[double-quoted-argument-unclosed]="fg=red"
HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]="fg=red"
HIGHLIGHT_STYLES[back-quoted-argument-unclosed]="fg=red"

HIGHLIGHT_STYLES[path]="underline"
#HIGHLIGHT_STYLES[path_pathseparator]=""
#HIGHLIGHT_STYLES[path_prefix_pathseparator]=""

HIGHLIGHT_STYLES[autodirectory]="fg=green,underline"

HIGHLIGHT_STYLES[globbing]="fg=blue"
HIGHLIGHT_STYLES[history-expansion]="fg=blue"

HIGHLIGHT_STYLES[command-substitution]="none"
HIGHLIGHT_STYLES[command-substitution-delimiter]="fg=magenta"

HIGHLIGHT_STYLES[process-substitution]="none"
HIGHLIGHT_STYLES[process-substitution-delimiter]="fg=magenta"

HIGHLIGHT_STYLES[rc-quote]="fg=cyan"

HIGHLIGHT_STYLES[assign]="none"
HIGHLIGHT_STYLES[named-fd]="none"
HIGHLIGHT_STYLES[numeric-fd]="none"
HIGHLIGHT_STYLES[arg0]="fg=green"

HIGHLIGHT_STYLES[unknown-token]="fg=red"

typeset -A ZSH_HIGHLIGHT_STYLES
set -A ZSH_HIGHLIGHT_STYLES ${(kv)HIGHLIGHT_STYLES}

typeset -A FAST_HIGHLIGHT_STYLES
set -A FAST_HIGHLIGHT_STYLES ${(kv)HIGHLIGHT_STYLES}

# History substring colors
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=white,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,bold'

# Selected item in menu list color
SELECTED_ITEM_MENULIST_COLOR="1;30;47"

# Su command
if [ -f ~/.zsh/su-zsh-plugin/su.plugin.zsh ]; then
	where doas >/dev/null && SU_COMMAND=doas ||
	where sudo >/dev/null && SU_COMMAND=sudo
fi

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

# Disowning - auto continue
setopt auto_continue

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

# Nerd Fonts
NERD_FONTS=1

# Prompt
# If you want a barebones classic prompt style, uncomment the following line and comment everything else
# PS1="%{$fg[yellow]%}%n@%{$fg[magenta]%}%M%{$fg[green]%}%~%{$reset_color%}%% "

# Source: Andy Kluger (@andykluger) from telegram group @zshell
# Readapted to my use case
local segments=()

segments+='%F{yellow}%n '					# user name
segments+='%F{green}%~'						# folder
segments+='$(git-status)'					# git info
segments+='$(nvm-version)'					# nvm version
segments+='%(?.. %F{red}%?%f)'				# retcode if non-zero
segments+='%F{white}'$'\n''%#%f '			# prompt symbol

PS1=${(j::)segments}

#
# Functions
#

# Source: https://github.com/agkozak/agkozak-zsh-prompt/
function git-status () {
	emulate -L zsh

	local ref branch
	ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
	case $? in			# See what the exit code is.
		0) ;;			# $ref contains the name of a checked-out branch.
		128) return ;;	# No Git repository here.
		# Otherwise, see if HEAD is in detached state.
		*) ref=$(command git rev-parse --short HEAD 2> /dev/null) || return ;;
	esac
	branch=${ref#refs/heads/}

	if [ -n "$branch" ]; then
		local git_status symbols i=1 k

		git_status="$(LC_ALL=C GIT_OPTIONAL_LOCKS=0 command git status --show-stash 2>&1)"

		typeset -A messages
		messages=(
			'&*'	' have diverged,'
			'&'		'Your branch is behind '
			'*'		'Your branch is ahead of '
			'+'		'new file:   '
			'x'		'deleted:    '
			'!'		'modified:   '
			'>'		'renamed:    '
			'?'		'Untracked files:'
		)

		for k in '&*' '&' '*' '+' 'x' '!' '>' '?'; do
			case $git_status in
				*${messages[$k]}*) symbols+="$k" ;;
			esac
			(( i++ ))
		done

		# Check for stashed changes. If there are any, add the stash symbol to the
		# list of symbols.
		case $git_status in
			*'Your stash currently has '*)
				symbols+="$"
				;;
		esac

		if [ -n "$branch" ]; then
			[ $NERD_FONTS -eq 1 ] &&
				branch=' %F{blue}'$'\ue725'" ${branch}" ||
				branch=" %F{blue}${branch}"
		fi

		[ -n "$symbols" ] && symbols=" %F{magenta}${symbols}"
		printf -- '%s%s' "$branch" "$symbols"
	fi
}

function nvm-version() {
	emulate -L zsh
	[ ! $NVM_DIR ] && return
	local nvmver
	nvmver=$(nvm version)
	[ "$nvmver" = "system" ] && return
	[ $NERD_FONTS -eq 1 ] &&
		nvmver=' %F{green}'$'\ue718'" ${nvmver:1}" ||
		nvmver=" %F{green}node-${nvmver:1}"
	printf -- '%s' "$nvmver"
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

# Source: https://github.com/phiresky/ripgrep-all
if where rga >/dev/null; then
	function rga-fzf() {
		RG_PREFIX="rga --files-with-matches"
		local file
		file="$(
			FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
				fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
					--phony -q "$1" \
					--bind "change:reload:$RG_PREFIX {q}" \
					--preview-window="70%:wrap"
		)" &&
		echo "opening $file" &&
		xdg-open "$file"
	}
fi

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

function dotenv() {
	if [ ! -f ".env" ]; then
		return
	fi

	echo -n "dotenv: found a dotenv file. Source it? (Y/n) "
	read -k 1 confirmation
	[ "$confirmation" = $'\n' ] || echo

	case "$confirmation" in
		[nN]) return ;;
		*) ;; # yes
	esac

	zsh -fn ".env" || echo "dotenv: error when sourcing, check syntax." >&2
	setopt localoptions allexport
	source ".env"
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
# ZSH Hooks
#

add-zsh-hook chpwd dotenv

#
# CLI tools load
#

# Fzf
if where fzf >/dev/null; then
	fzf_location=$(whence -S fzf)
	fzf_location=${fzf_location%/*}
	if [ -d "$fzf_location/shell" ]; then # We are inside a brew package
		source $fzf_location/shell/completion.zsh 2>/dev/null
		source $fzf_location/shell/key-bindings.zsh 2>/dev/null
	elif [ -d "$fzf_location/share/fzf" ]; then # We are inside /usr or /usr/local
		source $fzf_location/share/fzf/completion.zsh 2>/dev/null
		source $fzf_location/share/fzf/key-bindings.zsh 2>/dev/null
	fi
fi

# Node Version Manager
[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
source $NVM_DIR/nvm.sh

#
# Plugin loads (custom order)
#
function __plugin_loader(){
	if [ -f "$HOME/.zsh/plugins/$1" ]; then
		source "$HOME/.zsh/plugins/$1"
	elif [ -f "/usr/local/share/zsh/plugins/$1" ]; then
		source "/usr/local/share/zsh/plugins/$1"
	elif [ -f "/usr/share/zsh/plugins/$1" ]; then
		source "/usr/share/zsh/plugins/$1"
	else
		return 1
	fi
}

# Abbreviations
__plugin_loader zsh-abbr/zsh-abbr.plugin.zsh

# Autosuggestions
__plugin_loader zsh-autosuggestions/zsh-autosuggestions.zsh

# Fzf
if where fzf >/dev/null; then
	__plugin_loader fzf-tab/fzf-tab.plugin.zsh 2>/dev/null || true
fi

# Node Version Manager
__plugin_loader zsh-load-nvmrc/load-nvmrc.zsh || true

# Syntax highlighting
__plugin_loader fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ||
	__plugin_loader zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || true

# Su by pressing double ESC
__plugin_loader su-zsh-plugin/su.plugin.zsh || true

# History substring search
__plugin_loader zsh-history-substring-search/zsh-history-substring-search.zsh

#
# Keybinds
#

# Character deletion (for funky terminals)
#bindkey "^?" backward-delete-char							# Backspace
bindkey "${terminfo[kdch1]}" delete-char					# Delete

# Commandline editing
bindkey '^E' edit-command-line								# Ctrl+E

# Directory traversing
bindkey '^[[1;3D' cd-back									# Alt+Left
bindkey '^[[1;3C' cd-forward								# Alt+Right
bindkey '^[[1;3A' cd-up										# Alt+Up

# History navigation
bindkey "${terminfo[kpp]}" beginning-of-history				# PgUp
bindkey "${terminfo[knp]}" end-of-history					# PgDn
bindkey '^[[A' history-substring-search-up					# Up
bindkey '^[[B' history-substring-search-down				# Down

# Incremental search
bindkey "^R" history-incremental-search-backward			# Ctrl+R
bindkey "^S" history-incremental-search-forward				# Ctrl+S

# Line navigation
bindkey '^[[H' beginning-of-line							# Home
bindkey '^[[F' end-of-line									# End
bindkey "^[[1;5C" forward-word								# Ctrl+Right
bindkey "^[[1;5D" backward-word								# Ctrl+Left

# Menu selection
bindkey -M menuselect '^@' accept-and-infer-next-history	# Ctrl+Space

# Overwrite mode
bindkey "${terminfo[kich1]}" overwrite-mode					# Insert

#
# Completion setup
# This section is mainly copied over from https://github.com/seebi/zshrc/blob/master/completion.zsh
#

# Always tab complete
zstyle ':completion:*' insert-tab false

# Automatically rehash commands // Source: http://www.zsh.org/mla/users/2011/msg00531.html
zstyle ':completion:*' rehash true

# Case Insensitive -> Partial Word (cs) -> Substring completion
zstyle ':completion:*' matcher-list \
	'' \
	'm:{A-Záàâãåäæçéèêëíìîïñóòôöõøœúùûüa-zÁÀÂÃÅÄÆÇÉÈÊËÍÌÎÏÑÓÒÔÖÕØŒÚÙÛÜ}={a-zÁÀÂÃÅÄÆÇÉÈÊËÍÌÎÏÑÓÒÔÖÕØŒÚÙÛÜA-Záàâãåäæçéèêëíìîïñóòôöõøœúùûü}' \
	'r:|[._-]=* r:|=*' \
	'l:|=* r:|=*'

# Colors
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=${SELECTED_ITEM_MENULIST_COLOR}

# Comments
zstyle ':completion:*' verbose yes

# Content preview (fzf-tab)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'

# Fault tolerance (1 error on 3 characters)
zstyle ':completion:*' completer _complete _correct _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'

# Fzf based completion (zsh-autocomplete)
#zstyle ':autocomplete:tab:*' fzf-completion yes

# Git checkout sorting
zstyle ':completion:*:git-checkout:*' sort false

# Grouping
zstyle ':completion:*' group-name ''
zstyle ':completion:*:messages' format $'\e[01;35m -- %d -- \e[00;00m'
zstyle ':completion:*:warnings' format $'\e[01;31mNo matches found\e[00;00m'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:corrections' format $'\e[01;33m -- %d -- \e[00;00m'

# Group switching (fzf-tab)
zstyle ':fzf-tab:*' switch-group ',' '.'

# Menu selection
zstyle ':completion:*' menu select=1

# Special directories
zstyle ':completion:*' special-dirs true

# Status line
zstyle ':completion:*:default' select-prompt $'\e[01;35m -- %M    %P -- \e[00;00m'

# Tab key behaviour
zstyle ':autocomplete:tab:*' widget-style menu-complete

#
# Stuff that needs to be run when ZSH starts
#

# Initialize completion
compinit -d "$HOME/.cache/zsh/compdump"

# Use cod (completion daemon) if it is available in the system
where cod >/dev/null && source <(cod init $$ zsh) || true

# Source dotenv
dotenv
