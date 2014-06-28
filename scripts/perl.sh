#!/bin/bash

. `dirname "$0"`/.helpers.sh
umask 0077

perldir=$HOME/perl5
setup_runtime_dir `basename "$perldir"` perl

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
