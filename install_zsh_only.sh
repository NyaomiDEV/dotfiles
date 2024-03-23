#!/bin/sh
 
echo "Naomi's Zshrc! (Arch-based installer)"

packages="git zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-fast-syntax-highlighting"
optional_packages="cod fzf bat ttf-nerd-fonts-symbols"

git_packages="fzf-tab su-zsh-plugin"
typeset -A sources
sources[fzf-tab]="https://github.com/Aloxaf/fzf-tab.git"
sources[su-zsh-plugin]="https://github.com/NyaomiDEV/su-zsh-plugin.git"

not_found=""
optional_not_found=""

for package in $packages; do
	pacman -Qi "$package" >/dev/null 2>&1 || not_found="$not_found $package"
done

for package in $optional_packages; do
	pacman -Qi "$package" >/dev/null 2>&1 || optional_not_found="$optional_not_found $package"
done

if [ -n "$not_found" ]; then
	echo "---"
	echo "[!] Missing packages: $not_found"
	echo "[!] Please install them to ensure correct dotfiles functionality!"
	exit 1
fi

if [ -n "$optional_not_found" ]; then
	echo "---"
	echo "[!] Missing optional packages: $optional_not_found"
	echo "[!] Please install them to have the full experience!"
fi

mkdir -p $HOME/.zsh/plugins 2>/dev/null

for package in $git_packages; do
	[ ! -d "$HOME/.zsh/plugins/$package" ] && git clone "${sources[$package]}" "$HOME/.zsh/plugins/$package"
done

a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; BASEDIR=$(cd "$a"; pwd -P)

files=$(find "$BASEDIR" -type f \
	-name ".zshrc" -or \
	-name ".profile" -or \
	-name ".zprofile" -or \
	-name "aliasrc" -or \
	-name "shortcutrc")

oldIFS=$IFS
IFS=$'\n'

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

IFS=$oldIFS

