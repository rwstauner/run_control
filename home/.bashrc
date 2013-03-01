# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
# .bashrc

function source_rc_files () {
  local rc
  for rc in "$@"; do
    [[ -f "$rc" ]] && [[ -r "$rc" ]] && source "$rc"
  done
}

# Source global definitions
source_rc_files /etc/bash.bashrc /etc/bashrc

# different semantics than the typical pathmunge()
function add_to_path () {
  local after=false dir
  if [[ "$1" == "--after" ]]; then after=true; shift; fi
  for dir in "$@"; do
    if [[ -d "$dir" ]] && ! echo "$PATH" | grep -qE "(^|:)$dir(:|$)"; then
      if $after; then PATH="$PATH:$dir"; else PATH="$dir:$PATH"; fi
    fi
  done
}

# build $PATH
# add_to_path /opt/*/bin
add_to_path /opt/vagrant/bin
add_to_path /opt/imagemagick/bin
add_to_path $HOME/bin/contrib $HOME/bin

# load the rest
source_rc_files ~/.bashrc.d/* ~/.bashrc.local $EXTRA_BASHRC

#unset -f add_to_path source_rc_files
