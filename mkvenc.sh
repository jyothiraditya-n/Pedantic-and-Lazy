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
	command -v "$1" || {
		errcho "Please install '$1'."
		exit 1
	}
}

errcho() {
	printf "$0: Error: %s\n" "$*" >&2
}

warncho() {
	printf "$0: Warning: %s\n" "$*"
}

checkcmd mkvmerge
checkcmd ffmpeg

read -rp "Are there subtitles? [Y/n]: " subs_exist

read -rp "Video Track: " video_track
read -rp "Audio Track: " audio_track

case "$subs_exist" in [Yy] | [Yy][Ee][Ss])
	read -rp "Subtitles Track: " sub_track
;; esac

read -rp "Target File Size [Bytes]: " file_size

read -rp "Reduce Video Resolution? [Y/n]: " reduce_res
read -rp "Reduce Video Framerate? [Y/n]: " reduce_fps

case "$reduce_res" in [Yy] | [Yy][Ee][Ss])
	read -rp "New Video Resolution: " video_res
;; esac

case "$reduce_fps" in [Yy] | [Yy][Ee][Ss])
	read -rp "New Video Framerate: " video_fps
;; esac

read -rp "FFMpeg Tune [film / animation / stillimage]: " ffmpeg_tune

for i in "$@"; do
	if [[ "$i" != *.mkv ]]; then
		warncho "Ignoring '$i', because it's not an MKV file."
		continue
	fi
	
	(set -x; mkvmerge -o "..video.$i" -A -d "$video_track" -S -B -T \
		--no-chapters -M --no-global-tags "$i")

	(set -x; mv "..video.$i" ".video.$i")
	
	(set -x; mkvmerge -o "..audio.$i" -a "$audio_track" -D -S -B -T \
		--no-chapters -M --no-global-tags "$i")

	(set -x; mv "..audio.$i" ".audio.$i")
	
	case "$subs_exist" in [Yy] | [Yy][Ee][Ss])
		(set -x; mkvmerge -o "..subtitles.$i" -A -D -s "$sub_track" \
			-B -T --no-chapters -M --no-global-tags "$i")

		(set -x; mv "..subtitles.$i" ".subtitles.$i")
	;; esac

	(set -x; ffmpeg -i ".audio.$i" -c:a "aac" -b:a "160k" -ac "2" \
		"..encoded.audio.$i")

	(set -x; mv "..encoded.audio.$i" ".encoded.audio.$i")
done

size_used=0
video_length=0

for i in "$@"; do
	if [[ "$i" != *.mkv ]]; then continue; fi
	
	size_used=$(echo "$size_used + $(du -b ".encoded.audio.$i" | cut \
		-f1)" | bc -l)
	
	case "$subs_exist" in [Yy] | [Yy][Ee][Ss])
		size_used=$(echo "$size_used + $(du -b ".subtitles.$i" | cut \
			-f1)" | bc -l)
	;; esac
	
	video_length=$(echo "$video_length + $(ffprobe -v "error" \
		-show_entries "format=duration" \
		-of "default=noprint_wrappers=1:nokey=1" ".video.$i")" | bc \
		-l)
done

bitrate=$(echo "scale=0; (($file_size - $size_used) * 8) / ($video_length \
	* 1000)" | bc -l)

bitrate=$bitrate'k'

for i in "$@"; do
	if [[ "$i" != *.mkv ]]; then continue; fi
	
	case "$reduce_res" in [Yy] | [Yy][Ee][Ss])
		case "$reduce_fps" in [Yy] | [Yy][Ee][Ss])
			(set -x; ffmpeg -i ".video.$i" -c:v "libx264" \
				-b:v "$bitrate" -pass "1" \
				-vf "fps=fps=$video_fps,scale=$video_res,setsar=1" \
				-tune "$ffmpeg_tune" -f "null" -y "/dev/null")

			(set -x; ffmpeg -i ".video.$i" -c:v "libx264" \
				-b:v "$bitrate" -pass "2" \
				-vf "fps=fps=$video_fps,scale=$video_res,setsar=1" \
				-tune "$ffmpeg_tune" "..encoded.video.$i")
		;;

		[Nn] | [Nn][Oo])
			(set -x; ffmpeg -i ".video.$i" -c:v "libx264" \
				-b:v "$bitrate" -pass "1" \
				-vf "scale=$video_res,setsar=1" \
				-tune "$ffmpeg_tune" -f "null" -y "/dev/null")

			(set -x; ffmpeg -i ".video.$i" -c:v "libx264" \
				-b:v "$bitrate" -pass "2" \
				-vf "scale=$video_res,setsar=1" \
				-tune "$ffmpeg_tune" "..encoded.video.$i")
		;; esac
	;;

	[Nn] | [Nn][Oo])
		case "$reduce_fps" in [Yy] | [Yy][Ee][Ss])
			(set -x; ffmpeg -i ".video.$i" -c:v "libx264" \
				-b:v "$bitrate" -pass "1" \
				-vf "fps=fps=$video_fps" -tune "$ffmpeg_tune" \
				-f "null" -y "/dev/null")

			(set -x; ffmpeg -i ".video.$i" -c:v "libx264" \
				-b:v "$bitrate" -pass "2" \
				-vf "fps=fps=$video_fps" \
				-tune "$ffmpeg_tune" "..encoded.video.$i")
		;;

		[Nn] | [Nn][Oo])
			(set -x; ffmpeg -i ".video.$i" -c:v "libx264" \
				-b:v "$bitrate" -pass "1" \
				-tune "$ffmpeg_tune" -f "null" -y "/dev/null")

			(set -x; ffmpeg -i ".video.$i" -c:v "libx264" \
				-b:v "$bitrate" -pass "2" \
				-tune "$ffmpeg_tune" "..encoded.video.$i")
		;; esac
	;; esac
	
	(set -x; mv "..encoded.video.$i" ".encoded.video.$i")

	case "$subs_exist" in [Yy] | [Yy][Ee][Ss])
		(set -x; mkvmerge --title "" -o "..encoded.$i" \
			".encoded.video.$i" ".encoded.audio.$i" \
			".subtitles.$i")

		(set -x; mv "..encoded.$i" ".encoded.$i")

		(set -x; rm ".video.$i" ".audio.$i" ".subtitles.$i" \
			".encoded.video.$i")
	;;
	
	[Nn] | [Nn][Oo])
		(set -x; mkvmerge --title "" -o "..encoded.$i" \
			".encoded.video.$i" ".encoded.audio.$i")

		(set -x; mv "..encoded.$i" ".encoded.$i")

		(set -x; rm ".video.$i" ".audio.$i" ".encoded.video.$i")
	;; esac
	
	(set -x; rm ".encoded.audio.$i")
	(set -x; mv ".encoded.$i" "$i")
done
