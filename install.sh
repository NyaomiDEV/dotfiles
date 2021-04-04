#!/bin/sh

a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; BASEDIR=$(cd "$a"; pwd -P)

files=$(find $BASEDIR -type f -not -path "$BASEDIR/.git/*" -not -path "$BASEDIR/install.sh" -not -path "$BASEDIR/README.md")

for file in $files; do
	relative=$(realpath --relative-to="$BASEDIR" $file)
	echo [+] Setting up $relative
	if ([ -f "$HOME/$relative" ] && [ ! -L "$HOME/$relative" ]) || [ "$(realpath "$HOME/$relative")" != "$file" ]; then
		echo [-] Backing up your $relative to $relative.old
		mv "$HOME/$relative" "$HOME/$relative.old"
	fi
	ln -s "$file" "$HOME/$relative" 2>/dev/null
done

echo [!] All done! maybe
