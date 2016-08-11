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

force-pm () {
  pm="$1"
  perl -c -m"$pm" -e1 2> /dev/null || \
    cpanm -n "$pm"
}

if [[ `uname` == Darwin ]]; then

  force-pm X11::Keysyms
  $rc/mac/setup/keyboard

else

  apt uim
  configure-im uim

fi

`dirname $0`/compose_key.sh
