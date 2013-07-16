#!/bin/bash

[[ "`id -un`" == "vagrant" ]] || exec sudo -H -u vagrant "$0"

echo "$0"
vhome="/home/vagrant"
vhomerc="$vhome/.vagrant.rc/rc"
cd $vhome

function ensure_line () {
  local line="$1" file="$2"
  { test -e "$file" && grep -qFx "$line" "$file"; } || \
    echo "$line" >> "$file"
}

ensure_line "source $vhomerc/.bashrc" .bashrc

ensure_line "source-file $vhomerc/.tmux.conf" .tmux.conf

ensure_line "runtime $vhomerc/.vimrc" .tmux.conf

git config --global alias.st status
