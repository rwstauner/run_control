#!/bin/bash

version_ge () {
  perl -e '($s, $t) = map { [split /\./, (/([0-9.]+)/)[0]] } @ARGV; while(@$t){ shift(@$s) >= shift(@$t) or exit(1) }' -- "$@"
}

setup_runtime_dir () {
  local name="$1" homedir="${2:-$1}"

  root=$HOME/$homedir
  test -d "$root" || mkdir -p "$root"

  rcdir=$root/rc
  if ! [[ -d $rcdir ]]; then
    ln -s ~/run_control/$name $rcdir;
  fi
}
