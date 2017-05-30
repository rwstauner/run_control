#!/bin/bash

set -x
[[ `uname` = Darwin ]] || exit 1;

touch ~/.bash_sessions_disable

no_path_helper () {
  local file="$1"
  [[ -f "$file" ]] || return

  grep -qF '$NO_PATH_HELPER' "$file" || \
    sudo perl -l -p -i".bak-`date +%F`" -e '
      s/\[/[ -z "\$NO_PATH_HELPER" ] && [/ if $_ eq q{if [ -x /usr/libexec/path_helper ]; then};
    ' "$file"
}

no_path_helper /etc/zshenv
