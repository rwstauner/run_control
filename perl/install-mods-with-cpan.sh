#!/bin/bash

function cpan () {
  command cpan "$@" < /dev/null
}

cpan Test::Reporter::Transport::Socket CPAN::Reporter || exit

mods="`dirname $0`/install.txt"
test -e $mods && \
  cpan `grep -vE '#' "$mods"`

my_dists=$HOME/data/devel/projects/perl/my_dists.pl
test -x $my_dists && \
  cpan `$my_dists`
