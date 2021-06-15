#! /bin/bash

# Pedantic & Lazy Bash Scripts (C) 2020-2021 Jyothiraditya Nellakra

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later 
# version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.

errcho() {
	printf "$0: error: %s\n" "$*" >&2
}

warncho() {
	printf "$0: warning: %s\n" "$*"
}

checkcmd() {
	command -v "$1" || {
		errcho " cannot find command '$1'."
		exit 1
	}
}

from_image() {
	for j in "$@"; do
		(set -x; convert -resize "$page_res" "$j" ".$j")
		(set -x; convert ".$j" "${j%.*}.pdf")
		(set -x; rm ".$j")
	done
}

checkcmd convert
checkcmd pdftk
checkcmd unzip

read -rp "Page Resolution: " page_res

for i in "$@"; do
	if [ -d "$i" ]; then
		echo "> cd '$i/'"
		cd "$i/"

		from_image *

		echo "> cd ../"
		cd ../

		(set -x; pdftk "$i"/*.pdf cat output "$i.pdf")
		(set -x; rm "$i"/*.pdf)

		continue
	fi

	case "$i" in
	*.cbz)
		(set -x; mkdir ".$i/")
		(set -x; unzip "$i" -d ".$i/")

		echo "> cd '.$i/'"
		cd ".$i/"

		from_image *

		echo "> cd ../"
		cd ../

		(set -x; pdftk ".$i"/*.pdf cat output "${i%.*}.pdf")
		(set -x; rm -r ".$i")
	;;

	*)
		from_image "$i"
	;;
	esac
done