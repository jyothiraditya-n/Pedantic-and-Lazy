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
from_images() { for j in "$@"; do from_image "$j"; done; }
printerr() { printf "$0: error: %s\n" "$*" >&2; }

from_image() {
	(set -x; convert -resize "$page_res" "$1" ".$1")
	(set -x; convert ".$1" "${1%.*}.pdf")
	(set -x; rm ".$1")
}

checkcmd convert
checkcmd pdftk
checkcmd unzip

read -rp "Page Resolution: " page_res

for i in "$@"; do
	if [ -d "$i" ]; then
		cd "$i/"; echo "+ cd '$i/'"
		from_images *
		cd ../; echo "+ cd ../"

		(set -x; pdftk "$i"/*.pdf cat output "$i.pdf")
		(set -x; rm "$i"/*.pdf)
		continue
	fi

	case "$i" in
	*.cbz)
		(set -x; mkdir ".$i/")
		(set -x; unzip "$i" -d ".$i/")

		cd ".$i/"; echo "+ cd '.$i/'"
		from_images *
		cd ../; echo "+ cd ../"

		(set -x; pdftk ".$i"/*.pdf cat output "${i%.*}.pdf")
		(set -x; rm -r ".$i")
	;;

	*)
		from_images "$i"
	;;
	esac
done