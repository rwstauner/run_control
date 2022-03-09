#!/bin/bash

cpanm="$HOME/usr/bin/cpanm"
mkdir -p "${cpanm%/*}"

curl cpanmin.us > "$cpanm"
chmod 0755 "$cpanm"
"$cpanm" --local-lib=~/perl5 local::lib

env="$HOME/.zshrc.perl-local-lib"
echo 'eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)' > "$env"
grep -qF "$env" ~/.zshrc.local || \
  echo "source \"$env\"" >> ~/.zshrc.local
