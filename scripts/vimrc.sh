#!/bin/bash

name=vimrc

if ! [[ -d "$name" ]]; then
  remote="`git config remote.origin.url`"
  git clone "${remote/run_control/$name}" "$name"
fi

[[ -e "$HOME/.vim"   ]] || ln -s "run_control/$name" "$HOME/.vim"
[[ -e "$HOME/.vimrc" ]] || ln -s ".vim/vimrc"        "$HOME/.vimrc"
