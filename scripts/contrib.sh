#!/bin/bash

umask 0077
bin="$HOME/usr/bin"
completion="$HOME/usr/share/bash_completion.d/"
mkdir -p "$bin" "$completion"
chmod u+rx "$bin" "$completion"

function dl () {
  local dest="$1" url="$2"
  test -s "$dest" || wget "$url" -O "$dest"
}

function dl_bin () {
  local dest="$bin/$1"
  dl "$dest" "$2"
  chmod u+x "$dest"
}

function dl_cmp () {
  dl "$completion/$1.bashrc" "$2"
}

function gen_cmp () {
  local dest="$1"; shift
  dest="$completion/$dest.bashrc"
  test -s "$dest" || "$@" > "$dest"
}

dzil_repo_comp=$HOME/data/builds/github/dist-zilla/misc/dzil-bash_completion
if [[ -e $dzil_repo_comp ]]; then
  ln -s $dzil_repo_comp $completion/dzil.bashrc
else
  dl_cmp dzil https://github.com/rjbs/dist-zilla/raw/master/misc/dzil-bash_completion
fi

dl_cmp  vagrant   https://github.com/mitchellh/vagrant/raw/master/contrib/bash/completion.sh
dl_cmp  django    https://github.com/django/django/raw/master/extras/django_bash_completion

# python

gen_cmp 'pip'     pip completion --bash
