#!/bin/zsh

echo "Naomi's Zshrc! (macOS and other Linux distros installer)"

packages=(zsh-abbr zsh-autosuggestions zsh-history-substring-search zsh-fast-syntax-highlighting fzf-tab su-zsh-plugin)

typeset -A sources
sources[zsh-abbr]="https://github.com/olets/zsh-abbr.git"
sources[zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
sources[zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search.git"
sources[zsh-fast-syntax-highlighting]="https://github.com/zdharma/fast-syntax-highlighting.git"
sources[fzf-tab]="https://github.com/Aloxaf/fzf-tab.git"
sources[su-zsh-plugin]="https://github.com/NyaomiDEV/su-zsh-plugin.git"

mkdir -p $HOME/.zsh/plugins 2>/dev/null
for package in $packages; do
	[ ! -d "$HOME/.zsh/plugins/$package" ] && git clone "${sources[${package}]}" "$HOME/.zsh/plugins/$package"
done

a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; BASEDIR=$(cd "$a"; pwd -P)

files=($(find "$BASEDIR" -type f \
	-name ".zshrc" -or \
	-name ".profile" -or \
	-name ".zprofile" -or \
	-name "aliasrc" -or \
	-name "shortcutrc"))

for file in $files; do
	echo "---"
	relative=$(realpath --relative-to="$BASEDIR" $file)
	
	while
		echo -n "[?] Do you want to install $relative ? [Y/n]: "
		read answer
		if [ "$answer" = "n" ] || [ "$answer" = "N" ]; then
			echo "[-] Skipping $relative"
			continue 2
		fi
		[ -n "$answer" ] && [ "$answer" != "y" ] && [ "$answer" != "Y" ]
	do :; done
	
	echo "[+] Setting up $relative"
	mkdir -p $(dirname "$HOME/$relative") 2>/dev/null
	if ([ -f "$HOME/$relative" ] && [ ! -L "$HOME/$relative" ]) || ([ -e "$HOME/$relative" ] && [ "$(realpath "$HOME/$relative")" != "$file" ]); then
		echo "[-] Backing up your $relative to $relative.old"
		mv "$HOME/$relative" "$HOME/$relative.old"
	fi
	ln -s "$file" "$HOME/$relative" 2>/dev/null
done
