#!/bin/bash

# NOTE: cookie[-jar] stopped working with ~/ and $HOME/
# so just generate the file

file="$HOME/.curlrc"

rm -f "$file"
cat <<CURLRC > "$file"
# NOTE: this file is generated
# vim: set ro:

# spread firefox
#user-agent = "Mozilla/5.0 (X11; Linux i686; rv:5.0) Gecko/20100101 Firefox/5.0"

# "i download cookies" -- ziggy
# "cookies are for sometimes" -- cookie monster
cookie     = "$HOME/.curlrc.cookies"
cookie-jar = "$HOME/.curlrc.cookies"

# change the referrer when following 302's
#--referer ;auto

# Accept-Encoding: deflate, gzip
compressed
CURLRC

chmod 0400 "$file"
