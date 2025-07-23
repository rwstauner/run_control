#!/bin/bash

rc=$HOME/run_control
kb=$rc/keyboard

have () { command -v "$1" >&-; }

apt () {
  dpkg -s "$1" &> /dev/null || sudo apt-get install -y "$1"
}

configure-im () {
  im="$1"
  im-config -m | grep -qFx "$im" || \
    im-config -n "$im"
}

perl-mod () {
  pm="$1"; shift
  perl -c -m"$pm" -e1 2> /dev/null || \
    cpanm "$@" "$pm"
}

perl-mods () {
  perl-mod X11::Keysyms -n
}

if [[ `uname` == Darwin ]]; then

  perl-mods
  $rc/mac/setup/keyboard

elif have apt-get; then

  apt uim
  configure-im uim
  perl-mods

elif have pacman; then

  perl-mods

fi

`dirname $0`/compose_key.sh
