#!/bin/bash

dir=run_control

find-files () {
  find home/ `uname | tr A-Z a-z`/home -mindepth 1 -maxdepth 1 2>/dev/null | sort
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

generate-loader-file () {
  local file="$1" loader="$2"
  if ! grep -qFx "$loader" "$file"; then
    echo " Regenerating $file"

    # Remove to break symlinks, reset perms, etc.
    rm -f "$file"

    cat <<RC > "$file"
# generated
$loader

# Don't let naughty installers append lines and confuse me.
return
RC
  fi
}

setup-shell-files () {
  local shell="$1"
  generate-loader-file "$HOME/.${shell}rc" "source ~/run_control/$shell/loader.$shell"

  local profile="$HOME/.${shell}_profile"
  profile=${profile/zsh_/z};
  generate-loader-file "$profile" "source ~/run_control/$shell/profile.$shell"
}

setup-shell-files bash
setup-shell-files zsh
