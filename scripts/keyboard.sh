#!/bin/bash

rc=$HOME/run_control
kb=$rc/keyboard

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

if [[ `uname` == Darwin ]]; then

  perl-mod X11::Keysyms -n
  $rc/mac/setup/keyboard

else

  apt uim
  configure-im uim
  perl-mod X11::Keysyms

fi

`dirname $0`/compose_key.sh
