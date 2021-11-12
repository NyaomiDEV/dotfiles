#!/bin/sh
 
echo "Naomi's Zshrc!"

packages="git zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting"
optional_packages="zsh-fast-syntax-highlighting cod fzf bat ttf-nerd-fonts-symbols"

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

a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; BASEDIR=$(cd "$a"; pwd -P)

files=$(find "$BASEDIR" -type f -name ".zshrc" -or -name ".profile" -or -name ".zprofile")

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

mkdir -p $HOME/.zsh 2>/dev/null

echo "[+] fzf-tab plugin for Zsh"
[ -d "$HOME/.zsh/fzf-tab" ] || git clone "https://github.com/Aloxaf/fzf-tab.git" "$HOME/.zsh/fzf-tab"

echo "[+] su-zsh-plugin"
[ -d "$HOME/.zsh/su-zsh-plugin" ] || git clone "https://github.com/AryToNeX/su-zsh-plugin.git" "$HOME/.zsh/su-zsh-plugin"
