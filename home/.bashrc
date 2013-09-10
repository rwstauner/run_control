# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
# .bashrc

function source_rc_files () {
  local rc
  for rc in "$@"; do
    [[ -f "$rc" ]] && [[ -r "$rc" ]] && source "$rc"
  done
}

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

# source global definitions
source_rc_files /etc/bash.bashrc /etc/bashrc

TERM_IS_INTERACTIVE=false
[[ -n "$PS1" ]] && [[ "${TERM:-dumb}" != "dumb" ]] && TERM_IS_INTERACTIVE=true

# Build $PATH.
# Instead of adding /opt/*/bin to $PATH
# consider symlinking those scripts into ~/bin/contrib
# to keep the $PATH shorter so less searching is required.
add_to_path $HOME/bin/contrib $HOME/bin

# load the rest
source_rc_files ~/.bashrc.d/* ~/.bashrc.local $EXTRA_BASHRC
# completion after the others (so PATH is built, etc)
source_rc_files ~/.bashrc.d/completion.d/contrib/* ~/.bashrc.d/completion.d/*
