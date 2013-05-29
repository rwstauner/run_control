#!/bin/bash

completion="$HOME/.bashrc.d/completion.d/contrib"
mkdir -p "$completion"

function dl () {
  dest="$1" url="$2"
  test -e "$dest" || curl -sL "$url" > "$dest"
}

function dl_completion () {
  dl "$completion/$1.bashrc" "$2"
}

dl_completion django https://github.com/django/django/raw/master/extras/django_bash_completion
