#!/bin/bash

dir=run_control

find-files () {
  find home/ `uname | tr A-Z a-z`/home -mindepth 1 -maxdepth 1 2>&- | sort
}

link-to-home () {
  local src="$dir/$1"
  local dest="$HOME/${1##*/}"
  local filedesc=''

  if [[ -e "$dest" ]]; then
    if [[ "`readlink "$dest"`" == "$src" ]]; then
      echo -e " \033[33m already linked: $dest \033[00m " 1>&2
    else
      [[ -e "$dest" ]] && ! [[ -s "$dest" ]] && filedesc="empty"
      echo "  skipping pre-existing $filedesc file: $dest"
    fi
  else
    if [[ -h "$dest" ]]; then
      echo "removing broken symlink $dest (`readlink $dest`)"
      rm -vf "$dest"
    fi
    echo ln -s "$src" "$dest"
    ln -s "$src" "$dest"
  fi
}

find-files | while read file; do
  link-to-home "$file"
done

touch ~/.tmux.conf.local
