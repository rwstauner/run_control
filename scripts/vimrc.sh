#!/bin/bash

name=vimrc
umask 0022

if ! [[ -d "$name" ]]; then
  remote="`git config remote.origin.url`"
  git clone "${remote/run_control/$name}" "$name"
  make -C "$name"
fi

[[ -e "$HOME/.vim"   ]] || ln -sf "run_control/$name" "$HOME/.vim"
[[ -e "$HOME/.vimrc" ]] || ln -sf ".vim/vimrc"        "$HOME/.vimrc"
