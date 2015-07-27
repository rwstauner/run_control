#!/bin/bash

src=$HOME/.config
target=run_control/xdg_config

msg () {
cat <<HELP
  $src exists but isn't linked to $target
  Compare differences and then:
    ln -s $target $src
HELP
}

if [[ -d $src ]]; then
  if [[ `readlink $src` != $target ]]; then
    msg
  fi
else
  ln -s $target $src
fi
