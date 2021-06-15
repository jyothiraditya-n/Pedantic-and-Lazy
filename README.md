# Pedantic-and-Lazy
A collection of somewhat robust scripts, made out of kludged together code to
achieve very specific tasks I need done on a fairly reasonable basis. They'll
probably work fine for you too, but given me, I'd still wanna look over the
source code to ensure it actually works.

## Testing / Installing the Code

Run `make all` to run `shellcheck` on the script files. (You'll need to
have `shellcheck` installed for this to work.

The current list of dependencies for each of the scripts is the following:
- `convert` (Imagemagick),
- `ffmpeg` (FFMPEG),
- `mkvmerge` (MKVToolNix),
- `pdftk` (PDF Toolkit), and
- `unzip` (Zip-file decompression utility)


Run `make install` to install the script files and `make remove` to uninstall
them. The default folder is `~/.local/bin`, but you can specify a path by
running `DESTDIR=<XYZ> make install` or `DESTDIR=<XYZ> make remove`.
Alternatively you can change the line in the makefile that sets the `DESTDIR`
variable.

Notably, installing to root-protected folders won't work because the makefile
doesn't include `sudo` for privilege escalation. If you need it, you can
manually add `sudo` to the makefile or simply run the whole `make` process as
root. (The latter is terrible practice, but a few bad decisions never hurt
anyone, right? <sup>right?</sup>)

## If you find bugs,

Please email me at [jyothiraditya.n@gmail.com](mailto:jyothiraditya.n@gmail.com)
and I'll try fixing it as soon as I can, but beware that this software is
extremely extremely untested and undocumented; there's a high chance something
works perfectly for me and will delete all system data for you.

_Please back up all your important files before messing with these scripts._

## Forking My Code or Contributing

Do whatever you want really, just follow the licence, and while you can make a
formal bug report, pull request and stuff, I really don't think this project is
formal enough to need much of that. Though it's really up to whatever floats
your boat.

---

Have fun and enjoy!
