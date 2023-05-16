#!/bin/sh

if [ "$(whoami)" != "naomi" ]; then
	echo "This user is not naomi. It is not advised to use this script if you are not her, as it *WILL* add her personal configuration to your system."
	echo "If this is what you want, then modify this script by hand so that you can use it."
	# But then don't cry when your config gets fucked up
	exit 1
fi

echo "Naomi's Dotfiles!"

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
	-not -path "$BASEDIR/.git/*" \
	-not -path "$BASEDIR/install.sh" \
	-not -path "$BASEDIR/install_zsh_only.sh" \
	-not -path "$BASEDIR/install_zsh_only_mac.sh" \
	-not -path "$BASEDIR/README.md")

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
echo "---"

while
	echo "[!] The script can make some extra work that needs to be done manually otherwise."
	echo "[!] Please refer to the source to know what it does."
	echo -n "[?] Do you want the script to do the extra work for you? [Y/n]: "
	read answer
	if [ "$answer" = "n" ] || [ "$answer" = "N" ]; then
		echo "[-] Skipping the extra work"
		exit
	fi
	[ -n "$answer" ] && [ "$answer" != "y" ] && [ "$answer" != "Y" ]
do :; done

echo "[!] Doing the extra work now"

echo "[!] All done!"
