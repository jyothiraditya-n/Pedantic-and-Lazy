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

checkcmd() { command -v "$1" || { printerr "'$1' not installed."; exit 1; }; }
printerr() { printf "$0: Error: %s\n" "$*" >&2; }

generate() {
	if [[ ${1:0:1} == "#" ]]; then
		echo "$1" >> "/tmp/pal.quickc.h"
		cat "/tmp/pal.quickc.h" "/tmp/pal.quickc.txt"
		echo "}" >> "/tmp/pal.quickc.c"

		return
	fi

	cat "/tmp/pal.quickc.h" "/tmp/pal.quickc.txt"
	echo "$1" >> "/tmp/pal.quickc.c"
	echo "}" >> "/tmp/pal.quickc.c"
}

checkcmd gcc

if ! [ -d "$HOME/.config" ]; then mkdir -p "$HOME/.config" || exit 1; fi

if ! [ -f "$HOME/.config/pal.quickc.h" ]; then
	touch "$HOME/.config/pal.quickc.h" || exit 1
{
	echo "#include <assert.h>";      echo "#include <limits.h>"
	echo "#include <signal.h>";      echo "#include <stdlib.h>"
	echo "#include <ctype.h>";       echo "#include <locale.h>"
	echo "#include <stdarg.h>";      echo "#include <string.h>"
	echo "#include <errno.h>";       echo "#include <math.h>"
	echo "#include <stddef.h>";      echo "#include <time.h>"
	echo "#include <float.h>";       echo "#include <setjmp.h>"
	echo "#include <stdio.h>";

	echo "#include <iso646.h>";      echo "#include <wchar.h>"
	echo "#include <wctype.h>"

	echo "#include <complex.h>";     echo "#include <inttypes.h>"
	echo "#include <stdint.h>";      echo "#include <tgmath.h>"
	echo "#include <fenv.h>";        echo "#include <stdbool.h>"

	echo "#include <stdalign.h>";    echo "#include <stdatomic.h>"
	echo "#include <stdnoreturn.h>"; echo "#include <threads.h>"
	echo "#include <uchar.h>"

	echo "int main() {"
}	>> "$HOME/.config/pal.quickc.h"
fi

cp "$HOME/.config/pal.quickc.h" "/tmp/pal.quickc.h" || exit 1;
echo "" > "/tmp/pal.quickc.txt" || exit 1

while true; do
	read -rp "pal> " command
	generate "$command" > "/tmp/pal.quickc.c" || exit 1;

	while ! gcc -std="c11" "/tmp/pal.quickc.c" -o "/tmp/pal.quickc" -O0; do
		read -rp "> " command
		generate "$command" > "/tmp/pal.quickc.c" || exit 1;
	done

	echo "$command" >> "/tmp/pal.quickc.txt" || exit 1
	/tmp/pal.quickc
done