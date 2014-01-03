#!/bin/bash

umask 0077
perldir=$HOME/perl5
test -d "$perldir" || mkdir "$perldir"

perlrc=$perldir/rc
if ! [[ -d $perlrc ]]; then
  ln -s ~/run_control/perl $perlrc;
fi

pbrc=$perldir/perlbrew/etc/bashrc
# get perlbrew if it's already installed
test -f "$pbrc" && . "$pbrc"

which perlbrew &> /dev/null || \
  curl -L install.perlbrew.pl | bash

# update/activate perlbrew
test -f "$pbrc" && . "$pbrc"

which cpanm    &> /dev/null || \
  perlbrew install-cpanm

# TODO: perlbrew@std or local::lib
