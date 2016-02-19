#!/bin/bash

set -x
[[ `uname` = Darwin ]] || exit 1;

grep -qF '$NO_PATH_HELPER' /etc/zshenv || \
  sudo perl -l -p -i".bak-`date +%F`" -e '
    s/\[/[ -z "\$NO_PATH_HELPER" ] && [/ if $_ eq q{if [ -x /usr/libexec/path_helper ]; then};
  ' /etc/zshenv
