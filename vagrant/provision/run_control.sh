#!/bin/bash

# Run as vagrant user.
[[ "`id -un`" == "vagrant" ]] || exec sudo -H -u vagrant "$0"

vhome="/home/vagrant"
vhomerc="$vhome/.vagrant.rc/rc"
cd $vhome

function ensure_line () {
  local line="$1" file="$2"
  { test -e "$file" && grep -qFx "$line" "$file"; } || \
    echo "$line" >> "$file"
}

# Use source/load commands rather than overwriting with symlinks when possible.

ensure_line "source $vhomerc/.bashrc" .bashrc

ensure_line "load '$vhomerc/.irbrc'" .irbrc

ensure_line "source-file $vhomerc/.tmux.conf" .tmux.conf

ensure_line "source $vhomerc/.vimrc" .vimrc

git config --global alias.st status
