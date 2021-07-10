#! /bin/bash

# Pedantic & Lazy Bash Scripts (C) 2020-2021 Jyothiraditya Nellakra

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later 
# version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.

# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.

checkcmd() {
	command -v "$1" || { errcho "Please install '$1'."; exit 1; }
}

errcho() {
	printf "$0: Error: %s\n" "$*" >&2
}

checkcmd gcc
checkcmd editor

if ! [ -d "$HOME/.config" ]; then
	mkdir -p "$HOME/.config" || exit 1;
fi

if ! [ -f "$HOME/.config/pal.quickc.c" ]; then
	touch "$HOME/.config/pal.quickc.c" || exit 1
	echo "#include <stdio.h>" >> "$HOME/.config/pal.quickc.c"
	echo "#include <stdlib.h>" >> "$HOME/.config/pal.quickc.c"
	echo "" >> "$HOME/.config/pal.quickc.c"
	echo "int main() {" >> "$HOME/.config/pal.quickc.c"
	echo "	printf(\"Hello, World!\\n\");" >> "$HOME/.config/pal.quickc.c"
	echo "	exit(0);" >> "$HOME/.config/pal.quickc.c"
	echo "}" >> "$HOME/.config/pal.quickc.c"
fi

if ! [ -f "/tmp/pal.quickc.c" ]; then
	cp "$HOME/.config/pal.quickc.c" "/tmp/pal.quickc.c" || exit 1
fi

editor "/tmp/pal.quickc.c"; clear

while ! gcc -std="gnu99" "/tmp/pal.quickc.c" -o "/tmp/pal.quickc"; do
	read -p "Hit enter to continue"
	editor "/tmp/pal.quickc.c"; clear
done

/tmp/pal.quickc
exit $?