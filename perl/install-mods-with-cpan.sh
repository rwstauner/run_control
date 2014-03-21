#!/bin/bash

function cpan () {
  command cpan "$@" < /dev/null
}

cpan Test::Reporter::Transport::Socket CPAN::Reporter || exit

dir=`dirname $0`
mods="$dir/install.txt"
test -e $mods && \
  cpan `grep -vE '#' "$mods"`

my_dists=$dir/my_dists.pl
test -x $my_dists && \
  cpan `$my_dists`
