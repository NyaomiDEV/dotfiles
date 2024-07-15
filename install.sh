#!/bin/sh

beginswith() { case $2 in "$1"*) true;; *) false;; esac; }

if [ "$(whoami)" != "naomi" ]; then
	echo "This user is not naomi. It is not advised to use this script if you are not her, as it *WILL* add her personal configuration to your system."
	echo "If this is what you want, then modify this script by hand so that you can use it."
	# But then don't cry when your config gets fucked up
	exit 1
fi

echo "Naomi's Dotfiles!"

packages="git zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-fast-syntax-highlighting eza fzf ripgrep-all bat atuin ttf-nerd-fonts-symbols"
optional_packages="cod"

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
	echo "[!] Missing packages:$not_found"
	echo "[!] Please install them to ensure correct dotfiles functionality!"
	exit 1
fi

if [ -n "$optional_not_found" ]; then
	echo "---"
	echo "[!] Missing optional packages:$optional_not_found"
	echo "[!] Please install them to have the full experience!"
fi

mkdir -p "$HOME/.zsh/plugins" 2>/dev/null

for package in $git_packages; do
	if [ ! -d "$HOME/.zsh/plugins/$package" ]; then
		while
			echo -n "[?] Do you want to retrieve $package from Git? [Y/n]: "
			read answer
			if [ "$answer" = "n" ] || [ "$answer" = "N" ]; then
				echo "[-] Skipping $package"
				continue 2
			fi
			[ -n "$answer" ] && [ "$answer" != "y" ] && [ "$answer" != "Y" ]
		do :; done

		git clone "${sources[$package]}" "$HOME/.zsh/plugins/$package"
	fi
done

a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; BASEDIR=$(cd "$a"; pwd -P)

files="$(find "$BASEDIR" -type f \
	-not -path "$BASEDIR/.gitignore" \
	-not -path "$BASEDIR/.git/*" \
	-not -path "$BASEDIR/install.sh" \
	-not -path "$BASEDIR/README.md")"

oldIFS=$IFS
IFS=$'\n'

for file in $files; do
	echo "---"
	relative=$(realpath --relative-to="$BASEDIR" $file)
	destination="$HOME/$relative"
	if beginswith "dot-" "$relative"; then
		destination="$HOME/.${relative:4}"
	fi
	
	while
		echo -n "[?] Do you want to install $relative to $destination? [Y/n]: "
		read answer
		if [ "$answer" = "n" ] || [ "$answer" = "N" ]; then
			echo "[-] Skipping $relative"
			continue 2
		fi
		[ -n "$answer" ] && [ "$answer" != "y" ] && [ "$answer" != "Y" ]
	do :; done
	
	if ([ -f "$destination" ] && [ ! -L "$destination" ]) || ([ -e "$destination" ] && [ "$(realpath "$destination")" != "$file" ]); then
		echo "[-] Backing up $destination to $destination.old"
		mv "$destination" "$destination.old"
	fi
	echo "[+] Setting up $destination"
	mkdir -p "$(dirname "$destination")" 2>/dev/null
	[ -L "$destination" ] && rm "$destination" 2>/dev/null
	ln -s "$file" "$destination" 2>/dev/null
done

IFS=$oldIFS
echo "---"

echo "[!] All done!"
